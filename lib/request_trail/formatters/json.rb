# frozen_string_literal: true

require "json"

module RequestTrail
  module Formatters
    class JSON
      include Base

      def format(request, collector)
        payload = base_payload(request, collector)
        payload[:controller] = controller_payload(collector) if collector.action_duration_ms.positive?
        ::JSON.generate(payload)
      end

      private

      def base_payload(request, collector)
        {
          method: request.request_method,
          path: request.path,
          duration_ms: collector.elapsed_ms,
          sql: { count: collector.sql_count, duration_ms: collector.sql_duration_ms },
          cache: cache_payload(collector)
        }
      end

      def cache_payload(collector)
        {
          hits: collector.cache_hits,
          misses: collector.cache_misses,
          writes: collector.cache_writes,
          duration_ms: collector.cache_duration_ms
        }
      end

      def controller_payload(collector)
        {
          duration_ms: collector.action_duration_ms,
          view_duration_ms: collector.view_duration_ms
        }
      end
    end
  end
end
