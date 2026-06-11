# frozen_string_literal: true

RSpec.describe RequestTrail::Railtie do
  it "is a Rails::Railtie" do
    expect(described_class.ancestors).to include(Rails::Railtie)
  end

  it "defines the insert_middleware initializer" do
    names = described_class.initializers.map(&:name)
    expect(names).to include("request_trail.insert_middleware")
  end
end