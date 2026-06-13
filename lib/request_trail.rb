# frozen_string_literal: true

require_relative "request_trail/version"
require_relative "request_trail/configuration"
require_relative "request_trail/collector"
require_relative "request_trail/subscriber"
require_relative "request_trail/formatters/base"
require_relative "request_trail/formatter"
require_relative "request_trail/formatters/flame_graph"
require_relative "request_trail/formatters/json"
require_relative "request_trail/middleware"
require_relative "request_trail/railtie" if defined?(Rails::Railtie)

module RequestTrail
  class Error < StandardError; end

  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def formatter
      configuration.formatter
    end

    def reset!
      @configuration = nil
    end
  end
end
