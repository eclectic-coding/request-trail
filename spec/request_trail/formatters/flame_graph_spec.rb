# frozen_string_literal: true

RSpec.describe RequestTrail::Formatters::FlameGraph do
  subject(:formatter) { described_class.new }

  let(:env) { Rack::MockRequest.env_for("/orders", method: "GET") }
  let(:request) { Rack::Request.new(env) }

  let(:base_collector) do
    instance_double(
      RequestTrail::Collector,
      elapsed_ms: 50.0,
      sql_count: 3,
      sql_duration_ms: 20.0,
      cache_hits: 2,
      cache_misses: 0,
      cache_writes: 0,
      cache_duration_ms: 5.0,
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
      cache_writes: 0,
      cache_duration_ms: 2.0,
      action_duration_ms: 80.0,
      view_duration_ms: 22.0
    )
  end

  before { allow(formatter).to receive(:colorize?).and_return(false) }

  describe "#format — flat (no controller data)" do
    subject(:output) { formatter.format(request, base_collector) }

    it "includes the RequestTrail header" do
      expect(output).to include("[RequestTrail] GET /orders 50ms")
    end

    it "renders a full-width bar on the header line" do
      expect(output.lines.first).to include("█" * 36)
    end

    it "includes a sql row" do
      expect(output).to include("sql")
    end

    it "includes a cache row" do
      expect(output).to include("cache")
    end

    it "is 3 lines (header + sql + cache)" do
      expect(output.lines.count).to eq(3)
    end

    it "proportionally scales the sql bar" do
      sql_width = ((20.0 / 50.0) * 36).round
      expect(output).to include("█" * sql_width)
    end
  end

  describe "#format — tiered (with controller data)" do
    subject(:output) { formatter.format(request, tiered_collector) }

    it "includes the RequestTrail header" do
      expect(output).to include("[RequestTrail] GET /orders 100ms")
    end

    it "includes controller, sql, cache, and view rows" do
      expect(output).to include("controller")
      expect(output).to include("sql")
      expect(output).to include("cache")
      expect(output).to include("view")
    end

    it "is 5 lines (header + controller + sql + cache + view)" do
      expect(output.lines.count).to eq(5)
    end

    it "controller row is indented 2 spaces" do
      controller_line = output.lines[1]
      expect(controller_line).to start_with("  controller")
    end

    it "sql row is indented 4 spaces" do
      sql_line = output.lines[2]
      expect(sql_line).to start_with("    sql")
    end

    it "proportionally scales the controller bar" do
      controller_width = ((80.0 / 100.0) * 36).round
      expect(output.lines[1]).to include("█" * controller_width)
    end
  end

  describe "ANSI colour" do
    before { allow(formatter).to receive(:colorize?).and_return(true) }

    it "adds colour codes to bars when colorize? is true" do
      output = formatter.format(request, tiered_collector)
      expect(output).to include("\e[")
      expect(output).to include("\e[0m")
    end

    it "uses distinct colours for each layer" do
      output = formatter.format(request, tiered_collector)
      expect(output).to include("\e[34m")
      expect(output).to include("\e[33m")
      expect(output).to include("\e[32m")
      expect(output).to include("\e[35m")
    end
  end

  describe "#colorize?" do
    before { allow(formatter).to receive(:colorize?).and_call_original }

    it "delegates to $stdout.isatty" do
      allow($stdout).to receive(:isatty).and_return(false)
      expect(formatter.send(:colorize?)).to be(false)
    end
  end

  describe "zero-duration bars" do
    it "renders no bar characters for a zero-duration row" do
      allow(base_collector).to receive(:cache_duration_ms).and_return(0.0)
      output = formatter.format(request, base_collector)
      cache_line = output.lines.last
      expect(cache_line).not_to include("█")
    end
  end
end