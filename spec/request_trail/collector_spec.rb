# frozen_string_literal: true

RSpec.describe RequestTrail::Collector do
  describe ".start / .current / .stop" do
    it "starts with no current collector" do
      expect(described_class.current).to be_nil
    end

    it "sets and clears Thread.current storage" do
      described_class.start
      expect(described_class.current).to be_a(described_class)
      described_class.stop
      expect(described_class.current).to be_nil
    end
  end

  describe "#record_sql" do
    subject(:collector) { described_class.new }

    it "increments sql_count" do
      collector.record_sql(10.0)
      collector.record_sql(5.0)
      expect(collector.sql_count).to eq(2)
    end

    it "accumulates sql_duration_ms" do
      collector.record_sql(10.0)
      collector.record_sql(5.5)
      expect(collector.sql_duration_ms).to be_within(0.01).of(15.5)
    end

    it "initializes with zero counts" do
      expect(collector.sql_count).to eq(0)
      expect(collector.sql_duration_ms).to eq(0.0)
    end
  end

  describe "#record_cache_read" do
    subject(:collector) { described_class.new }

    it "increments cache_hits on a hit" do
      collector.record_cache_read(hit: true, duration_ms: 1.0)
      expect(collector.cache_hits).to eq(1)
      expect(collector.cache_misses).to eq(0)
    end

    it "increments cache_misses on a miss" do
      collector.record_cache_read(hit: false, duration_ms: 1.0)
      expect(collector.cache_misses).to eq(1)
      expect(collector.cache_hits).to eq(0)
    end

    it "accumulates cache_duration_ms" do
      collector.record_cache_read(hit: true, duration_ms: 1.5)
      collector.record_cache_read(hit: false, duration_ms: 2.0)
      expect(collector.cache_duration_ms).to be_within(0.01).of(3.5)
    end

    it "initializes with zero cache counts" do
      expect(collector.cache_hits).to eq(0)
      expect(collector.cache_misses).to eq(0)
      expect(collector.cache_writes).to eq(0)
      expect(collector.cache_duration_ms).to eq(0.0)
    end
  end

  describe "#record_action" do
    subject(:collector) { described_class.new }

    it "sets action_duration_ms" do
      collector.record_action(duration_ms: 104.0, view_duration_ms: 22.0)
      expect(collector.action_duration_ms).to eq(104.0)
    end

    it "sets view_duration_ms" do
      collector.record_action(duration_ms: 104.0, view_duration_ms: 22.0)
      expect(collector.view_duration_ms).to eq(22.0)
    end

    it "initializes with zero action and view durations" do
      expect(collector.action_duration_ms).to eq(0.0)
      expect(collector.view_duration_ms).to eq(0.0)
    end

    it "overwrites on repeated calls" do
      collector.record_action(duration_ms: 50.0, view_duration_ms: 10.0)
      collector.record_action(duration_ms: 104.0, view_duration_ms: 22.0)
      expect(collector.action_duration_ms).to eq(104.0)
    end
  end

  describe "#record_cache_write" do
    subject(:collector) { described_class.new }

    it "increments cache_writes" do
      collector.record_cache_write(duration_ms: 2.0)
      collector.record_cache_write(duration_ms: 1.0)
      expect(collector.cache_writes).to eq(2)
    end

    it "accumulates cache_duration_ms" do
      collector.record_cache_write(duration_ms: 3.0)
      expect(collector.cache_duration_ms).to be_within(0.01).of(3.0)
    end
  end

  describe "#elapsed_ms" do
    it "returns a non-negative value" do
      collector = described_class.new
      expect(collector.elapsed_ms).to be >= 0
    end

    it "increases over time" do
      collector = described_class.new
      first = collector.elapsed_ms
      sleep 0.01
      expect(collector.elapsed_ms).to be > first
    end
  end
end