# frozen_string_literal: true

require_relative "trail/version"
require_relative "trail/configuration"
require_relative "trail/collector"
require_relative "trail/subscriber"
require_relative "trail/formatter"
require_relative "trail/middleware"
require_relative "trail/railtie" if defined?(Rails::Railtie)

module Request
  module Trail
    class Error < StandardError; end

    class << self
      def configure
        yield configuration
      end

      def configuration
        @configuration ||= Configuration.new
      end

      def formatter
        @formatter ||= Formatter.new
      end

      def reset!
        @configuration = nil
        @formatter = nil
      end
    end
  end
end
