# frozen_string_literal: true

module RequestTrail
  class Formatter
    def format(request, collector)
      header = "[RequestTrail] #{request.request_method} #{request.path}"
      "#{header} #{collector.elapsed_ms.round}ms | #{sql_summary(collector)} | #{cache_summary(collector)}"
    end

    private

    def sql_summary(collector)
      "SQL: #{collector.sql_count}/#{collector.sql_duration_ms.round(1)}ms"
    end

    def cache_summary(collector)
      hit_label  = collector.cache_hits == 1 ? "hit" : "hits"
      miss_label = collector.cache_misses == 1 ? "miss" : "misses"
      duration   = collector.cache_duration_ms.round(1)
      "Cache: #{collector.cache_hits} #{hit_label}, #{collector.cache_misses} #{miss_label}, #{duration}ms"
    end
  end
end
