# frozen_string_literal: true

RSpec.describe RequestTrail::LogTag do
  describe "RequestTrail.log_tag" do
    it "returns a callable" do
      expect(RequestTrail.log_tag).to respond_to(:call)
    end

    it "returns a Value instance when called" do
      expect(RequestTrail.log_tag.call(nil)).to be_a(RequestTrail::LogTag::Value)
    end
  end

  describe RequestTrail::LogTag::Value do
    describe "#to_s" do
      context "when no collector is active" do
        it "returns an empty string" do
          expect(described_class.new.to_s).to eq("")
        end
      end

      context "when a collector is active" do
        before { RequestTrail::Collector.start }
        after  { RequestTrail::Collector.stop }

        it "includes the current SQL count" do
          expect(described_class.new.to_s).to include("sql=0")
        end

        it "includes elapsed time in milliseconds" do
          expect(described_class.new.to_s).to match(/\d+ms/)
        end

        it "reflects SQL recorded after construction" do
          value = described_class.new
          RequestTrail::Collector.current.record_sql(5.0)
          expect(value.to_s).to include("sql=1")
        end
      end
    end

    describe "#blank?" do
      context "when no collector is active" do
        it "returns true" do
          expect(described_class.new.blank?).to be(true)
        end
      end

      context "when a collector is active" do
        before { RequestTrail::Collector.start }
        after  { RequestTrail::Collector.stop }

        it "returns false" do
          expect(described_class.new.blank?).to be(false)
        end
      end
    end
  end
end