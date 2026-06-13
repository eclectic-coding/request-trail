# frozen_string_literal: true

module RequestTrail
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) unless RequestTrail.configuration.enabled
      return @app.call(env) if RequestTrail.configuration.ignored_path?(env["PATH_INFO"])
      return @app.call(env) unless RequestTrail.configuration.sampled?

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
      return if elapsed < RequestTrail.configuration.threshold_ms

      request = Rack::Request.new(env)
      message = RequestTrail.formatter.format(request, collector)
      RequestTrail.configuration.logger.send(RequestTrail.configuration.log_level, message)
    end
  end
end
