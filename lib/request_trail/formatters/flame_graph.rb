# frozen_string_literal: true

module RequestTrail
  module Formatters
    class FlameGraph
      include Base

      BAR_WIDTH = 36
      BAR_CHAR  = "█"

      COLORS = {
        header: "\e[1m",
        controller: "\e[34m",
        sql: "\e[33m",
        cache: "\e[32m",
        view: "\e[35m"
      }.freeze
      RESET = "\e[0m"

      def initialize(colorize: false)
        @colorize = colorize
      end

      def format(request, collector)
        total = collector.elapsed_ms.to_f
        lines = [header_line(request, collector)] + detail_rows(collector, total)
        lines.join("\n")
      end

      private

      def detail_rows(collector, total)
        return tiered_rows(collector, total) if collector.action_duration_ms.positive?

        flat_rows(collector, total)
      end

      def tiered_rows(collector, total)
        [
          row("  ", "controller", collector.action_duration_ms, total, :controller),
          row("    ", "sql",      collector.sql_duration_ms,    total, :sql),
          row("    ", "cache",    collector.cache_duration_ms,  total, :cache),
          row("    ", "view",     collector.view_duration_ms,   total, :view)
        ]
      end

      def flat_rows(collector, total)
        [
          row("  ", "sql",   collector.sql_duration_ms,   total, :sql),
          row("  ", "cache", collector.cache_duration_ms, total, :cache)
        ]
      end

      def header_line(request, collector)
        elapsed = collector.elapsed_ms.round
        bar = BAR_CHAR * BAR_WIDTH
        line = "[RequestTrail] #{request.request_method} #{request.path} #{elapsed}ms #{bar}"
        return line unless colorize?

        "#{COLORS[:header]}#{line}#{RESET}"
      end

      def row(indent, label, duration_ms, total_ms, color_key)
        ms = duration_ms.round
        bar = colorized_bar(duration_ms, total_ms, color_key)
        "#{indent}#{label.ljust(11)}#{ms.to_s.rjust(4)}ms #{bar}"
      end

      def colorized_bar(duration_ms, total_ms, color_key)
        width = total_ms.positive? ? ((duration_ms.to_f / total_ms) * BAR_WIDTH).round : 0
        bar = BAR_CHAR * width
        return bar unless colorize? && width.positive?

        "#{COLORS[color_key]}#{bar}#{RESET}"
      end

      def colorize?
        @colorize
      end
    end
  end
end
