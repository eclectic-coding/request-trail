# frozen_string_literal: true

RSpec.describe RequestTrail::Configuration do
  subject(:config) { described_class.new }

  describe "defaults" do
    it { expect(config.enabled).to be true }
    it { expect(config.log_level).to eq(:info) }
    it { expect(config.threshold_ms).to eq(0) }
  end

  describe "setters" do
    it "allows setting enabled" do
      config.enabled = false
      expect(config.enabled).to be false
    end

    it "allows setting log_level" do
      config.log_level = :debug
      expect(config.log_level).to eq(:debug)
    end

    it "allows setting threshold_ms" do
      config.threshold_ms = 100
      expect(config.threshold_ms).to eq(100)
    end
  end

  describe "#logger" do
    context "when explicitly set" do
      let(:custom_logger) { instance_double(Logger) }

      it "returns the assigned logger" do
        config.logger = custom_logger
        expect(config.logger).to be(custom_logger)
      end
    end

    context "when Rails.logger is available" do
      let(:rails_logger) { instance_double(Logger) }

      before { allow(Rails).to receive(:logger).and_return(rails_logger) }

      it "returns Rails.logger" do
        expect(config.logger).to be(rails_logger)
      end
    end

    context "when Rails.logger is nil" do
      before { allow(Rails).to receive(:logger).and_return(nil) }

      it "returns a stdlib Logger" do
        expect(config.logger).to be_a(Logger)
      end
    end
  end
end