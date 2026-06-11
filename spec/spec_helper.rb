require "simplecov"
require "simplecov_json_formatter"

SimpleCov.start do
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::JSONFormatter
  ])
  add_filter "/spec/"
  add_filter "/version.rb"
  track_files "lib/**/*.rb"
end# frozen_string_literal: true

require "rack"
require "active_support"
require "rails/railtie"

require "request/trail"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after do
    Request::Trail.reset!
    Request::Trail::Collector.stop
    Request::Trail::Subscriber.detach
  end
end
