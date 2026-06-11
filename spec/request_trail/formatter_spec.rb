# frozen_string_literal: true

RSpec.describe RequestTrail::Formatter do
  subject(:formatter) { described_class.new }

  let(:env) { Rack::MockRequest.env_for("/orders", method: "GET") }
  let(:request) { Rack::Request.new(env) }

  let(:base_collector) do
    instance_double(
      RequestTrail::Collector,
      elapsed_ms: 142.5,
      sql_count: 7,
      sql_duration_ms: 38.3,
      cache_hits: 4,
      cache_misses: 1,
      cache_writes: 2,
      cache_duration_ms: 2.0,
      action_duration_ms: 0.0,
      view_duration_ms: 0.0
    )
  end

  let(:tiered_collector) do
    instance_double(
      RequestTrail::Collector,
      elapsed_ms: 142.5,
      sql_count: 7,
      sql_duration_ms: 38.3,
      cache_hits: 4,
      cache_misses: 1,
      cache_writes: 2,
      cache_duration_ms: 2.0,
      action_duration_ms: 104.0,
      view_duration_ms: 22.0
    )
  end

  describe "#format — single-line (no controller data)" do
    subject(:output) { formatter.format(request, base_collector) }

    it "includes the RequestTrail prefix" do
      expect(output).to include("[RequestTrail]")
    end

    it "includes the request method and path" do
      expect(output).to include("GET /orders")
    end

    it "includes the elapsed time" do
      expect(output).to include("143ms")
    end

    it "includes sql count and duration" do
      expect(output).to include("SQL: 7/38.3ms")
    end

    it "uses plural 'hits' for multiple cache hits" do
      expect(output).to include("4 hits")
    end

    it "uses singular 'hit' for one cache hit" do
      allow(base_collector).to receive(:cache_hits).and_return(1)
      expect(formatter.format(request, base_collector)).to include("1 hit")
    end

    it "uses singular 'miss' for one cache miss" do
      expect(output).to include("1 miss")
    end

    it "uses plural 'misses' for multiple cache misses" do
      allow(base_collector).to receive(:cache_misses).and_return(2)
      expect(formatter.format(request, base_collector)).to include("2 misses")
    end

    it "includes cache duration" do
      expect(output).to include("2.0ms")
    end
  end

  describe "#format — tiered (with controller data)" do
    subject(:output) { formatter.format(request, tiered_collector) }

    it "includes the header line" do
      expect(output).to include("[RequestTrail] GET /orders 143ms")
    end

    it "includes the controller duration" do
      expect(output).to include("controller  104ms")
    end

    it "includes sql with query count" do
      expect(output).to include("38.3ms (7 queries)")
    end

    it "uses singular 'query' for one query" do
      allow(tiered_collector).to receive(:sql_count).and_return(1)
      expect(formatter.format(request, tiered_collector)).to include("1 query")
    end

    it "includes cache detail with hits and misses" do
      expect(output).to include("4 hits, 1 miss")
    end

    it "includes view duration" do
      expect(output).to include("view       22.0ms")
    end

    it "is multi-line" do
      expect(output.lines.count).to eq(5)
    end
  end
end