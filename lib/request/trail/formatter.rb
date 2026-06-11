# frozen_string_literal: true

module Request
  module Trail
    class Formatter
      def format(request, collector)
        header = "[RequestTrail] #{request.request_method} #{request.path}"
        "#{header} #{collector.elapsed_ms.round}ms | #{sql_summary(collector)}"
      end

      private

      def sql_summary(collector)
        label = collector.sql_count == 1 ? "query" : "queries"
        "SQL: #{collector.sql_count} #{label} / #{collector.sql_duration_ms.round(1)}ms"
      end
    end
  end
end
