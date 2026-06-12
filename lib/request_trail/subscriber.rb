# frozen_string_literal: true

module RequestTrail
  class Subscriber
    SQL_EVENT         = "sql.active_record"
    CACHE_READ_EVENT  = "cache_read.active_support"
    CACHE_WRITE_EVENT = "cache_write.active_support"
    ACTION_EVENT      = "process_action.action_controller"

    def self.attach
      @attach ||= [sql_subscription, cache_read_subscription, cache_write_subscription, action_subscription]
    end

    def self.detach
      return unless @attach

      @attach&.each { |sub| ActiveSupport::Notifications.unsubscribe(sub) }
      @attach = nil
    end

    private_class_method def self.sql_subscription
      ActiveSupport::Notifications.subscribe(SQL_EVENT) do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        Collector.current&.record_sql(event.duration)
      end
    end

    private_class_method def self.cache_read_subscription
      ActiveSupport::Notifications.subscribe(CACHE_READ_EVENT) do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        Collector.current&.record_cache_read(
          hit: event.payload.fetch(:hit, false),
          duration_ms: event.duration
        )
      end
    end

    private_class_method def self.cache_write_subscription
      ActiveSupport::Notifications.subscribe(CACHE_WRITE_EVENT) do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        Collector.current&.record_cache_write(duration_ms: event.duration)
      end
    end

    private_class_method def self.action_subscription
      ActiveSupport::Notifications.subscribe(ACTION_EVENT) do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        Collector.current&.record_action(
          duration_ms: event.duration,
          view_duration_ms: event.payload.fetch(:view_runtime, 0.0)
        )
      end
    end
  end
end
