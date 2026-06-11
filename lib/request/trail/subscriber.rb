# frozen_string_literal: true

module Request
  module Trail
    class Subscriber
      SQL_EVENT = "sql.active_record"

      def self.attach
        @attach ||= ActiveSupport::Notifications.subscribe(SQL_EVENT) do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)
          Collector.current&.record_sql(event.duration)
        end
      end

      def self.detach
        return unless @attach

        ActiveSupport::Notifications.unsubscribe(@attach)
        @attach = nil
      end
    end
  end
end
