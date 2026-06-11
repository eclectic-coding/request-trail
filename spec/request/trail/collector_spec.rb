# frozen_string_literal: true

RSpec.describe Request::Trail::Collector do
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