# frozen_string_literal: true

module RequestTrail
  class SidekiqMiddleware
    JobContext = Struct.new(:request_method, :path, keyword_init: true)

    def call(_worker, job, _queue)
      return yield unless RequestTrail.configuration.enabled
      return yield unless RequestTrail.configuration.sampled?

      Collector.start
      yield
      log(job)
    ensure
      Collector.stop
    end

    private

    def log(job)
      collector = Collector.current
      elapsed = collector.elapsed_ms
      return if elapsed < RequestTrail.configuration.threshold_ms

      context = JobContext.new(
        request_method: "JOB",
        path: "#{job["class"]} jid:#{job["jid"]}"
      )
      message = RequestTrail.formatter.format(context, collector)
      RequestTrail.configuration.logger.send(RequestTrail.configuration.log_level, message)
    end
  end
end
