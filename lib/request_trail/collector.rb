# frozen_string_literal: true

module RequestTrail
  class Collector
    THREAD_KEY = :request_trail_collector

    attr_reader :sql_count, :sql_duration_ms,
                :cache_hits, :cache_misses, :cache_writes, :cache_duration_ms,
                :action_duration_ms, :view_duration_ms

    def self.current
      Thread.current[THREAD_KEY]
    end

    def self.start
      Thread.current[THREAD_KEY] = new
    end

    def self.stop
      Thread.current[THREAD_KEY] = nil
    end

    def initialize
      @started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      @sql_count = 0
      @sql_duration_ms = 0.0
      @cache_hits = 0
      @cache_misses = 0
      @cache_writes = 0
      @cache_duration_ms = 0.0
      @action_duration_ms = 0.0
      @view_duration_ms = 0.0
    end

    def record_sql(duration_ms)
      @sql_count += 1
      @sql_duration_ms += duration_ms
    end

    def record_cache_read(hit:, duration_ms:)
      hit ? @cache_hits += 1 : @cache_misses += 1
      @cache_duration_ms += duration_ms
    end

    def record_cache_write(duration_ms:)
      @cache_writes += 1
      @cache_duration_ms += duration_ms
    end

    def record_action(duration_ms:, view_duration_ms:)
      @action_duration_ms = duration_ms
      @view_duration_ms = view_duration_ms
    end

    def elapsed_ms
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @started_at
      (elapsed * 1000).round(2)
    end
  end
end
