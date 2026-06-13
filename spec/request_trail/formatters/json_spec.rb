# frozen_string_literal: true

require "json"

RSpec.describe RequestTrail::Formatters::JSON do
  subject(:formatter) { described_class.new }

  let(:env) { Rack::MockRequest.env_for("/orders", method: "GET") }
  let(:request) { Rack::Request.new(env) }

  let(:flat_collector) do
    instance_double(
      RequestTrail::Collector,
      elapsed_ms: 50.2,
      sql_count: 3,
      sql_duration_ms: 20.5,
      cache_hits: 2,
      cache_misses: 1,
      cache_writes: 0,
      cache_duration_ms: 5.1,
      action_duration_ms: 0.0,
      view_duration_ms: 0.0
    )
  end

  let(:tiered_collector) do
    instance_double(
      RequestTrail::Collector,
      elapsed_ms: 100.0,
      sql_count: 7,
      sql_duration_ms: 38.0,
      cache_hits: 4,
      cache_misses: 1,
      cache_writes: 1,
      cache_duration_ms: 2.0,
      action_duration_ms: 80.0,
      view_duration_ms: 22.0
    )
  end

  describe "#format" do
    context "without controller data (flat)" do
      subject(:output) { ::JSON.parse(formatter.format(request, flat_collector)) }

      it "includes method and path" do
        expect(output).to include("method" => "GET", "path" => "/orders")
      end

      it "includes total duration" do
        expect(output["duration_ms"]).to eq(50.2)
      end

      it "includes sql metrics" do
        expect(output["sql"]).to eq("count" => 3, "duration_ms" => 20.5)
      end

      it "includes cache metrics" do
        expect(output["cache"]).to eq(
          "hits" => 2, "misses" => 1, "writes" => 0, "duration_ms" => 5.1
        )
      end

      it "omits the controller key" do
        expect(output).not_to have_key("controller")
      end

      it "produces valid JSON" do
        expect { formatter.format(request, flat_collector) }.not_to raise_error
      end
    end

    context "with controller data (tiered)" do
      subject(:output) { ::JSON.parse(formatter.format(request, tiered_collector)) }

      it "includes controller duration and view duration" do
        expect(output["controller"]).to eq(
          "duration_ms" => 80.0, "view_duration_ms" => 22.0
        )
      end

      it "still includes sql and cache metrics" do
        expect(output["sql"]["count"]).to eq(7)
        expect(output["cache"]["hits"]).to eq(4)
      end
    end
  end

  describe "includes Formatters::Base" do
    it { expect(described_class.ancestors).to include(RequestTrail::Formatters::Base) }
  end
end