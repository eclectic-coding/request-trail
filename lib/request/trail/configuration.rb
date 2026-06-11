# frozen_string_literal: true

require "logger"

module Request
  module Trail
    class Configuration
      attr_writer :logger
      attr_accessor :enabled, :log_level, :threshold_ms

      def initialize
        @enabled = true
        @log_level = :info
        @threshold_ms = 0
      end

      def logger
        @logger ||= rails_logger || Logger.new($stdout)
      end

      private

      def rails_logger
        Rails.logger if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
      end
    end
  end
end
