# frozen_string_literal: true

RSpec.describe Request::Trail do
  it "has a version number" do
    expect(Request::Trail::VERSION).not_to be nil
  end

end
