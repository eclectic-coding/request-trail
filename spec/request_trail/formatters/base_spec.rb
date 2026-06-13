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

  describe "built-in formatters" do
    it "Formatter includes Base" do
      expect(RequestTrail::Formatter.ancestors).to include(described_class)
    end

    it "Formatters::FlameGraph includes Base" do
      expect(RequestTrail::Formatters::FlameGraph.ancestors).to include(described_class)
    end
  end
end