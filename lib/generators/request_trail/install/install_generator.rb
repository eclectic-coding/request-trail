# frozen_string_literal: true

return unless defined?(Rails::Generators)

require "rails/generators"

module RequestTrail
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      desc "Creates a RequestTrail initializer in config/initializers"

      def copy_initializer
        template "request_trail.rb.tt", "config/initializers/request_trail.rb"
      end
    end
  end
end
