# frozen_string_literal: true

RSpec.describe RequestTrail::Configuration do
  subject(:config) { described_class.new }

  describe "defaults" do
    it { expect(config.enabled).to be true }
    it { expect(config.log_level).to eq(:info) }
    it { expect(config.threshold_ms).to eq(0) }
    it { expect(config.ignore_paths).to eq([]) }
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

    it "allows setting ignore_paths" do
      config.ignore_paths = ["/health", /^\/assets/]
      expect(config.ignore_paths).to eq(["/health", /^\/assets/])
    end
  end

  describe "#ignored_path?" do
    context "with string patterns" do
      before { config.ignore_paths = ["/health", "/favicon.ico"] }

      it "returns true for an exact match" do
        expect(config.ignored_path?("/health")).to be true
      end

      it "returns false for a non-matching path" do
        expect(config.ignored_path?("/orders")).to be false
      end
    end

    context "with regex patterns" do
      before { config.ignore_paths = [/^\/assets/] }

      it "returns true when the regex matches" do
        expect(config.ignored_path?("/assets/app.js")).to be true
      end

      it "returns false when the regex does not match" do
        expect(config.ignored_path?("/orders")).to be false
      end
    end

    context "with mixed string and regex patterns" do
      before { config.ignore_paths = ["/health", /^\/assets/] }

      it "matches against the string" do
        expect(config.ignored_path?("/health")).to be true
      end

      it "matches against the regex" do
        expect(config.ignored_path?("/assets/app.css")).to be true
      end

      it "returns false when nothing matches" do
        expect(config.ignored_path?("/orders")).to be false
      end
    end

    context "when ignore_paths is empty" do
      it "returns false for any path" do
        expect(config.ignored_path?("/health")).to be false
      end
    end
  end

  describe "#formatter" do
    it "defaults to a Formatter instance" do
      expect(config.formatter).to be_a(RequestTrail::Formatter)
    end

    it "memoizes the default" do
      expect(config.formatter).to be(config.formatter)
    end

    it "accepts a custom formatter" do
      custom = RequestTrail::Formatters::FlameGraph.new
      config.formatter = custom
      expect(config.formatter).to be(custom)
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