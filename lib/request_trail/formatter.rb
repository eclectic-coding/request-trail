# frozen_string_literal: true

module RequestTrail
  class Formatter
    include Formatters::Base

    def format(request, collector)
      n1 = n_plus_one?(collector) ? " [N+1?]" : ""
      header = "[RequestTrail] #{request.request_method} #{request.path} #{collector.elapsed_ms.round}ms#{n1}"
      return tiered_format(header, collector) if collector.action_duration_ms.positive?

      "#{header} | #{sql_summary(collector)} | #{cache_summary(collector)} | #{http_summary(collector)}"
    end

    private

    def tiered_format(header, collector)
      [
        header,
        "  controller  #{collector.action_duration_ms.round}ms",
        "    sql        #{collector.sql_duration_ms.round(1)}ms (#{sql_count_label(collector)})",
        "    cache      #{collector.cache_duration_ms.round(1)}ms (#{cache_detail(collector)})",
        "    view       #{collector.view_duration_ms.round(1)}ms",
        "    http       #{collector.http_duration_ms.round(1)}ms (#{http_count_label(collector)})"
      ].join("\n")
    end

    def sql_summary(collector)
      "SQL: #{collector.sql_count}/#{collector.sql_duration_ms.round(1)}ms"
    end

    def cache_summary(collector)
      hit_label  = collector.cache_hits == 1 ? "hit" : "hits"
      miss_label = collector.cache_misses == 1 ? "miss" : "misses"
      duration   = collector.cache_duration_ms.round(1)
      "Cache: #{collector.cache_hits} #{hit_label}, #{collector.cache_misses} #{miss_label}, #{duration}ms"
    end

    def http_summary(collector)
      "HTTP: #{collector.http_count}/#{collector.http_duration_ms.round(1)}ms"
    end

    def http_count_label(collector)
      collector.http_count == 1 ? "1 call" : "#{collector.http_count} calls"
    end

    def sql_count_label(collector)
      collector.sql_count == 1 ? "1 query" : "#{collector.sql_count} queries"
    end

    def cache_detail(collector)
      hit_label  = collector.cache_hits == 1 ? "hit" : "hits"
      miss_label = collector.cache_misses == 1 ? "miss" : "misses"
      "#{collector.cache_hits} #{hit_label}, #{collector.cache_misses} #{miss_label}"
    end
  end
end
