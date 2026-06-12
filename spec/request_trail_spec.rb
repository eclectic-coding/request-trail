# frozen_string_literal: true

RSpec.describe RequestTrail do
  it "has a version number" do
    expect(RequestTrail::VERSION).not_to be_nil
  end

  describe ".configure" do
    it "yields the configuration" do
      described_class.configure { |c| c.enabled = false }
      expect(described_class.configuration.enabled).to be false
    end
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(described_class.configuration).to be_a(RequestTrail::Configuration)
    end

    it "memoizes" do
      expect(described_class.configuration).to be(described_class.configuration)
    end
  end

  describe ".formatter" do
    it "returns a Formatter instance by default" do
      expect(described_class.formatter).to be_a(RequestTrail::Formatter)
    end

    it "memoizes via configuration" do
      expect(described_class.formatter).to be(described_class.formatter)
    end

    it "returns a custom formatter when set via configuration" do
      custom = RequestTrail::Formatters::FlameGraph.new
      described_class.configure { |c| c.formatter = custom }
      expect(described_class.formatter).to be(custom)
    end
  end

  describe ".reset!" do
    it "clears memoized configuration" do
      original_config = described_class.configuration
      described_class.reset!
      expect(described_class.configuration).not_to be(original_config)
    end

    it "clears the formatter via configuration reset" do
      original_formatter = described_class.formatter
      described_class.reset!
      expect(described_class.formatter).not_to be(original_formatter)
    end
  end
end