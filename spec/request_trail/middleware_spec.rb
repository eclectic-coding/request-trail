# frozen_string_literal: true

RSpec.describe RequestTrail::Middleware do
  let(:inner_app) { ->(_env) { [200, {}, ["OK"]] } }
  let(:middleware) { described_class.new(inner_app) }
  let(:logger) { instance_double(Logger, info: nil) }
  let(:env) { Rack::MockRequest.env_for("/orders", method: "GET") }

  before { RequestTrail.configuration.logger = logger }

  describe "#call" do
    it "returns the inner app response" do
      status, _headers, body = middleware.call(env)
      expect(status).to eq(200)
      expect(body).to eq(["OK"])
    end

    it "logs the request summary" do
      middleware.call(env)
      expect(logger).to have_received(:info).with(a_string_including("[RequestTrail] GET /orders"))
    end

    it "clears the collector after the request" do
      middleware.call(env)
      expect(RequestTrail::Collector.current).to be_nil
    end

    context "when disabled" do
      before { RequestTrail.configuration.enabled = false }

      it "passes through without tracing" do
        middleware.call(env)
        expect(logger).not_to have_received(:info)
      end

      it "still returns the response" do
        status, = middleware.call(env)
        expect(status).to eq(200)
      end
    end

    context "when the path matches ignore_paths" do
      before { RequestTrail.configuration.ignore_paths = ["/health", /^\/assets/] }

      it "passes through without tracing for an exact string match" do
        health_env = Rack::MockRequest.env_for("/health", method: "GET")
        middleware.call(health_env)
        expect(logger).not_to have_received(:info)
      end

      it "passes through without tracing for a regex match" do
        asset_env = Rack::MockRequest.env_for("/assets/app.js", method: "GET")
        middleware.call(asset_env)
        expect(logger).not_to have_received(:info)
      end

      it "still returns the response" do
        health_env = Rack::MockRequest.env_for("/health", method: "GET")
        status, = middleware.call(health_env)
        expect(status).to eq(200)
      end

      it "still traces paths not in ignore_paths" do
        middleware.call(env)
        expect(logger).to have_received(:info)
      end
    end

    context "when the request is not sampled" do
      before { allow(RequestTrail.configuration).to receive(:sampled?).and_return(false) }

      it "passes through without tracing" do
        middleware.call(env)
        expect(logger).not_to have_received(:info)
      end

      it "still returns the response" do
        status, = middleware.call(env)
        expect(status).to eq(200)
      end
    end

    context "when threshold_ms is set above request duration" do
      before { RequestTrail.configuration.threshold_ms = 100_000 }

      it "skips logging" do
        middleware.call(env)
        expect(logger).not_to have_received(:info)
      end
    end

    context "when the inner app raises" do
      let(:inner_app) { ->(_env) { raise "boom" } }

      it "re-raises the error" do
        expect { middleware.call(env) }.to raise_error("boom")
      end

      it "clears the collector" do
        middleware.call(env) rescue nil
        expect(RequestTrail::Collector.current).to be_nil
      end
    end
  end
end