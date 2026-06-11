require "rails_helper"

RSpec.describe "RequestTrail middleware", type: :request do
  let(:log_output) { StringIO.new }
  let(:logger) { Logger.new(log_output) }

  before { RequestTrail.configuration.logger = logger }

  describe "GET /ping" do
    it "logs a tiered summary with controller and view times" do
      get "/ping"

      expect(response).to have_http_status(:ok)
      log_output.rewind
      output = log_output.read
      expect(output).to include("[RequestTrail] GET /ping")
      expect(output).to include("controller")
      expect(output).to include("sql")
      expect(output).to include("cache")
      expect(output).to include("view")
    end

    it "includes the response time in the summary" do
      get "/ping"

      log_output.rewind
      expect(log_output.read).to match(/\d+ms/)
    end

    context "when disabled" do
      before { RequestTrail.configuration.enabled = false }

      it "does not log anything" do
        get "/ping"

        log_output.rewind
        expect(log_output.read).not_to include("[RequestTrail]")
      end
    end

    context "when threshold_ms is set above request duration" do
      before { RequestTrail.configuration.threshold_ms = 100_000 }

      it "does not log anything" do
        get "/ping"

        log_output.rewind
        expect(log_output.read).not_to include("[RequestTrail]")
      end
    end
  end
end