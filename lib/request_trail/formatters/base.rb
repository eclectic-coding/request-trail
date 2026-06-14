# frozen_string_literal: true

module RequestTrail
  module Formatters
    # Mixin that documents the formatter duck-type contract.
    # Include it in custom formatters to make the interface explicit;
    # the only required method is #format(request, collector) -> String.
    module Base
      # @param request  [Rack::Request]
      # @param collector [RequestTrail::Collector]
      # @return [String] the log line(s) to emit
      def format(_request, _collector)
        raise NotImplementedError, "#{self.class}#format must return a String"
      end

      private

      def n_plus_one?(collector)
        threshold = RequestTrail.configuration.n_plus_one_threshold
        threshold ? collector.sql_count >= threshold : false
      end
    end
  end
end
