# frozen_string_literal: true

module RequestTrail
  module LogTag
    class Value
      def to_s
        collector = Collector.current
        return "" unless collector

        "sql=#{collector.sql_count} #{collector.elapsed_ms.round}ms"
      end

      def blank?
        to_s.empty?
      end
    end
  end
end
