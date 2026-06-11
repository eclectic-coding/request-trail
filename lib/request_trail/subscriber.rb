# frozen_string_literal: true

module RequestTrail
  class Subscriber
    SQL_EVENT         = "sql.active_record"
    CACHE_READ_EVENT  = "cache_read.active_support"
    CACHE_WRITE_EVENT = "cache_write.active_support"

    def self.attach
      @attach ||= [sql_subscription, cache_read_subscription, cache_write_subscription]
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
  end
end
