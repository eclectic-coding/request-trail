# frozen_string_literal: true

module Request
  module Trail
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        return @app.call(env) unless Trail.configuration.enabled

        Collector.start
        response = @app.call(env)
        log(env)
        response
      ensure
        Collector.stop
      end

      private

      def log(env)
        collector = Collector.current
        elapsed = collector.elapsed_ms
        return if elapsed < Trail.configuration.threshold_ms

        request = Rack::Request.new(env)
        message = Trail.formatter.format(request, collector)
        Trail.configuration.logger.send(Trail.configuration.log_level, message)
      end
    end
  end
end
