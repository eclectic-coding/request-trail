ENV["RAILS_ENV"] ||= "test"

require_relative "dummy/config/environment"
require "rspec/rails"

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before(:each, type: :request) do
    RequestTrail.configure do |c|
      c.enabled = true
      c.threshold_ms = 0
    end
    RequestTrail::Subscriber.attach
  end

  config.after(:each, type: :request) do
    RequestTrail.reset!
    RequestTrail::Subscriber.detach
  end
end