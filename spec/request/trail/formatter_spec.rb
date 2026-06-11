# frozen_string_literal: true

RSpec.describe Request::Trail::Formatter do
  subject(:formatter) { described_class.new }

  let(:env) { Rack::MockRequest.env_for("/orders", method: "GET") }
  let(:request) { Rack::Request.new(env) }
  let(:collector) { instance_double(Request::Trail::Collector, elapsed_ms: 142.5, sql_count: 7, sql_duration_ms: 38.3) }

  describe "#format" do
    it "includes the request method and path" do
      expect(formatter.format(request, collector)).to include("GET /orders")
    end

    it "includes the elapsed time" do
      expect(formatter.format(request, collector)).to include("143ms")
    end

    it "includes the RequestTrail prefix" do
      expect(formatter.format(request, collector)).to include("[RequestTrail]")
    end

    it "uses plural 'queries' for multiple sql queries" do
      expect(formatter.format(request, collector)).to include("7 queries")
    end

    it "uses singular 'query' for one sql query" do
      allow(collector).to receive(:sql_count).and_return(1)
      expect(formatter.format(request, collector)).to include("1 query")
    end

    it "includes sql duration" do
      expect(formatter.format(request, collector)).to include("38.3ms")
    end
  end
end