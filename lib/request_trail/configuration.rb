# frozen_string_literal: true

require "logger"

module RequestTrail
  class Configuration
    attr_writer :logger, :formatter
    attr_accessor :enabled, :log_level, :threshold_ms, :ignore_paths, :sample_rate

    def initialize
      @enabled = true
      @log_level = :info
      @threshold_ms = 0
      @ignore_paths = []
      @sample_rate = 1.0
    end

    def sampled?
      rand < sample_rate
    end

    def ignored_path?(path)
      ignore_paths.any? { |pattern| path_matches?(pattern, path) }
    end

    def logger
      @logger ||= rails_logger || Logger.new($stdout)
    end

    def formatter
      @formatter ||= RequestTrail::Formatter.new
    end

    private

    def path_matches?(pattern, path)
      case pattern
      when Regexp then pattern.match?(path)
      else pattern == path
      end
    end

    def rails_logger
      Rails.logger if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
    end
  end
end
