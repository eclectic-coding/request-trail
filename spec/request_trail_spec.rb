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
    it "returns a Formatter instance" do
      expect(described_class.formatter).to be_a(RequestTrail::Formatter)
    end

    it "memoizes" do
      expect(described_class.formatter).to be(described_class.formatter)
    end
  end

  describe ".reset!" do
    it "clears memoized configuration and formatter" do
      original_config = described_class.configuration
      original_formatter = described_class.formatter
      described_class.reset!
      expect(described_class.configuration).not_to be(original_config)
      expect(described_class.formatter).not_to be(original_formatter)
    end
  end
end