# frozen_string_literal: true

RSpec.describe RequestTrail::Formatters::Base do
  let(:formatter_class) do
    Class.new do
      include RequestTrail::Formatters::Base
    end
  end

  describe "#format" do
    it "raises NotImplementedError when not overridden" do
      formatter = formatter_class.new
      expect { formatter.format(double, double) }.to raise_error(NotImplementedError)
    end

    it "is satisfied by any object that overrides #format" do
      formatter_class.define_method(:format) { |_req, _col| "custom output" }
      expect(formatter_class.new.format(double, double)).to eq("custom output")
    end
  end

  describe "#n_plus_one?" do
    let(:formatter) do
      formatter_class.define_method(:format) { |_req, _col| "ok" }
      formatter_class.new
    end
    let(:collector) { instance_double(RequestTrail::Collector, sql_count: 5) }

    context "when n_plus_one_threshold is nil (disabled)" do
      it "returns false" do
        expect(formatter.send(:n_plus_one?, collector)).to be false
      end
    end

    context "when sql_count is below the threshold" do
      before { RequestTrail.configuration.n_plus_one_threshold = 10 }

      it "returns false" do
        expect(formatter.send(:n_plus_one?, collector)).to be false
      end
    end

    context "when sql_count equals the threshold" do
      before { RequestTrail.configuration.n_plus_one_threshold = 5 }

      it "returns true" do
        expect(formatter.send(:n_plus_one?, collector)).to be true
      end
    end

    context "when sql_count exceeds the threshold" do
      before { RequestTrail.configuration.n_plus_one_threshold = 3 }

      it "returns true" do
        expect(formatter.send(:n_plus_one?, collector)).to be true
      end
    end
  end

  describe "built-in formatters" do
    it "Formatter includes Base" do
      expect(RequestTrail::Formatter.ancestors).to include(described_class)
    end

    it "Formatters::FlameGraph includes Base" do
      expect(RequestTrail::Formatters::FlameGraph.ancestors).to include(described_class)
    end
  end
end