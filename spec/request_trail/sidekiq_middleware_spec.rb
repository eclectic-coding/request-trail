# frozen_string_literal: true

require "request_trail/sidekiq_middleware"

RSpec.describe RequestTrail::SidekiqMiddleware do
  let(:middleware) { described_class.new }
  let(:worker)     { double("worker") }
  let(:job)        { { "class" => "HardWorker", "jid" => "abc123", "args" => [] } }
  let(:queue)      { "default" }
  let(:logger)     { instance_double(Logger, info: nil) }

  before { RequestTrail.configuration.logger = logger }

  def run(**opts, &block)
    j = opts[:job] || job
    middleware.call(worker, j, queue, &block)
  end

  describe "#call" do
    it "yields to the job" do
      expect { |b| run(&b) }.to yield_control
    end

    it "logs a summary after the job" do
      run {}
      expect(logger).to have_received(:info).with(a_string_including("[RequestTrail] JOB HardWorker jid:abc123"))
    end

    it "clears the collector after the job" do
      run {}
      expect(RequestTrail::Collector.current).to be_nil
    end

    context "when disabled" do
      before { RequestTrail.configuration.enabled = false }

      it "still yields" do
        expect { |b| run(&b) }.to yield_control
      end

      it "does not log" do
        run {}
        expect(logger).not_to have_received(:info)
      end
    end

    context "when not sampled" do
      before { allow(RequestTrail.configuration).to receive(:sampled?).and_return(false) }

      it "still yields" do
        expect { |b| run(&b) }.to yield_control
      end

      it "does not log" do
        run {}
        expect(logger).not_to have_received(:info)
      end
    end

    context "when threshold_ms is set above job duration" do
      before { RequestTrail.configuration.threshold_ms = 100_000 }

      it "skips logging" do
        run {}
        expect(logger).not_to have_received(:info)
      end
    end

    context "when the job raises" do
      it "re-raises the error" do
        expect { run { raise "boom" } }.to raise_error("boom")
      end

      it "clears the collector" do
        run { raise "boom" } rescue nil
        expect(RequestTrail::Collector.current).to be_nil
      end

      it "does not log" do
        run { raise "boom" } rescue nil
        expect(logger).not_to have_received(:info)
      end
    end

    context "with a custom formatter" do
      let(:formatter) { instance_double(RequestTrail::Formatters::JSON) }

      before do
        allow(formatter).to receive(:format).and_return("{}")
        RequestTrail.configuration.formatter = formatter
      end

      it "passes a JobContext as the request object" do
        run {}
        expect(formatter).to have_received(:format) do |context, _collector|
          expect(context.request_method).to eq("JOB")
          expect(context.path).to eq("HardWorker jid:abc123")
        end
      end
    end
  end

  describe RequestTrail::SidekiqMiddleware::JobContext do
    it "exposes request_method and path" do
      ctx = described_class.new(request_method: "JOB", path: "MyWorker jid:xyz")
      expect(ctx.request_method).to eq("JOB")
      expect(ctx.path).to eq("MyWorker jid:xyz")
    end
  end
end