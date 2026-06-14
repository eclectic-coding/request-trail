# frozen_string_literal: true

require "active_job"
require "request_trail/active_job_subscriber"

RSpec.describe RequestTrail::ActiveJobSubscriber do
  let(:logger) { instance_double(Logger, info: nil) }

  before { RequestTrail.configuration.logger = logger }

  let(:job_class) do
    Class.new(ActiveJob::Base) do
      include RequestTrail::ActiveJobSubscriber

      def perform; end
    end
  end

  let(:raising_job_class) do
    Class.new(ActiveJob::Base) do
      include RequestTrail::ActiveJobSubscriber

      def perform
        raise "boom"
      end
    end
  end

  describe "around_perform hook" do
    it "runs the job" do
      performed = false
      klass = Class.new(ActiveJob::Base) do
        include RequestTrail::ActiveJobSubscriber
        define_method(:perform) { performed = true }
      end
      klass.new.perform_now
      expect(performed).to be true
    end

    it "logs a summary after the job" do
      job_class.new.perform_now
      expect(logger).to have_received(:info).with(a_string_including("[RequestTrail] JOB"))
    end

    it "includes the job_id in the log output" do
      job = job_class.new
      job.perform_now
      expect(logger).to have_received(:info).with(a_string_including("jid:#{job.job_id}"))
    end

    it "clears the collector after the job" do
      job_class.new.perform_now
      expect(RequestTrail::Collector.current).to be_nil
    end

    context "when disabled" do
      before { RequestTrail.configuration.enabled = false }

      it "still runs the job" do
        performed = false
        klass = Class.new(ActiveJob::Base) do
          include RequestTrail::ActiveJobSubscriber
          define_method(:perform) { performed = true }
        end
        klass.new.perform_now
        expect(performed).to be true
      end

      it "does not log" do
        job_class.new.perform_now
        expect(logger).not_to have_received(:info)
      end
    end

    context "when not sampled" do
      before { allow(RequestTrail.configuration).to receive(:sampled?).and_return(false) }

      it "does not log" do
        job_class.new.perform_now
        expect(logger).not_to have_received(:info)
      end
    end

    context "when threshold_ms is set above job duration" do
      before { RequestTrail.configuration.threshold_ms = 100_000 }

      it "skips logging" do
        job_class.new.perform_now
        expect(logger).not_to have_received(:info)
      end
    end

    context "when the job raises" do
      it "re-raises the error" do
        expect { raising_job_class.new.perform_now }.to raise_error("boom")
      end

      it "clears the collector" do
        raising_job_class.new.perform_now rescue nil
        expect(RequestTrail::Collector.current).to be_nil
      end

      it "does not log" do
        raising_job_class.new.perform_now rescue nil
        expect(logger).not_to have_received(:info)
      end
    end

    context "with a custom formatter" do
      let(:formatter) { instance_double(RequestTrail::Formatters::JSON) }

      before do
        allow(formatter).to receive(:format).and_return("{}")
        RequestTrail.configuration.formatter = formatter
      end

      it "passes a JobContext with request_method JOB" do
        job_class.new.perform_now
        expect(formatter).to have_received(:format) do |context, _collector|
          expect(context.request_method).to eq("JOB")
          expect(context.path).to include("jid:")
        end
      end
    end
  end

  describe RequestTrail::ActiveJobSubscriber::JobContext do
    it "exposes request_method and path" do
      ctx = described_class.new(request_method: "JOB", path: "MyJob jid:xyz")
      expect(ctx.request_method).to eq("JOB")
      expect(ctx.path).to eq("MyJob jid:xyz")
    end
  end
end