# frozen_string_literal: true

module Request
  module Trail
    class Railtie < Rails::Railtie
      # :nocov:
      initializer "request_trail.insert_middleware" do |app|
        app.middleware.use(Request::Trail::Middleware)
        Subscriber.attach
      end
      # :nocov:
    end
  end
end
