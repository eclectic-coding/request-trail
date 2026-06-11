require_relative "boot"

require "rails"
require "action_controller/railtie"
require "active_support/railtie"

module Dummy
  class Application < Rails::Application
    config.load_defaults 8.0
    config.eager_load = false
    config.logger = Logger.new(nil)
    config.log_level = :debug
  end
end