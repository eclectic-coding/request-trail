# frozen_string_literal: true

module RequestTrail
  module ActiveJobSubscriber
    JobContext = Struct.new(:request_method, :path, keyword_init: true)

    def self.included(base)
      base.around_perform { |job, block| RequestTrail::ActiveJobSubscriber.trace(job, block) }
    end

    def self.trace(job, block)
      if RequestTrail.configuration.enabled && RequestTrail.configuration.sampled?
        Collector.start
        block.call
        log(job)
      else
        block.call
      end
    ensure
      Collector.stop
    end

    def self.log(job)
      collector = Collector.current
      return if collector.elapsed_ms < RequestTrail.configuration.threshold_ms

      message = RequestTrail.formatter.format(build_context(job), collector)
      RequestTrail.configuration.logger.send(RequestTrail.configuration.log_level, message)
    end

    def self.build_context(job)
      JobContext.new(
        request_method: "JOB",
        path: "#{job.class.name || job.class.to_s} jid:#{job.job_id}"
      )
    end
  end
end
