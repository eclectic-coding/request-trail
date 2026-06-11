# frozen_string_literal: true

RSpec.describe RequestTrail::Formatter do
  subject(:formatter) { described_class.new }

  let(:env) { Rack::MockRequest.env_for("/orders", method: "GET") }
  let(:request) { Rack::Request.new(env) }
  let(:collector) do
    instance_double(
      RequestTrail::Collector,
      elapsed_ms: 142.5,
      sql_count: 7,
      sql_duration_ms: 38.3,
      cache_hits: 4,
      cache_misses: 1,
      cache_writes: 2,
      cache_duration_ms: 2.0
    )
  end

  describe "#format" do
    it "includes the RequestTrail prefix" do
      expect(formatter.format(request, collector)).to include("[RequestTrail]")
    end

    it "includes the request method and path" do
      expect(formatter.format(request, collector)).to include("GET /orders")
    end

    it "includes the elapsed time" do
      expect(formatter.format(request, collector)).to include("143ms")
    end

    it "includes sql count and duration" do
      expect(formatter.format(request, collector)).to include("SQL: 7/38.3ms")
    end

    it "uses plural 'hits' for multiple cache hits" do
      expect(formatter.format(request, collector)).to include("4 hits")
    end

    it "uses singular 'hit' for one cache hit" do
      allow(collector).to receive(:cache_hits).and_return(1)
      expect(formatter.format(request, collector)).to include("1 hit")
    end

    it "uses singular 'miss' for one cache miss" do
      expect(formatter.format(request, collector)).to include("1 miss")
    end

    it "uses plural 'misses' for multiple cache misses" do
      allow(collector).to receive(:cache_misses).and_return(2)
      expect(formatter.format(request, collector)).to include("2 misses")
    end

    it "includes cache duration" do
      expect(formatter.format(request, collector)).to include("2.0ms")
    end
  end
end