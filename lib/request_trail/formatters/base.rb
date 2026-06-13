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
    end
  end
end
