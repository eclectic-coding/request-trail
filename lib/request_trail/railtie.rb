# frozen_string_literal: true

module RequestTrail
  class Railtie < Rails::Railtie
    # :nocov:
    initializer "request_trail.insert_middleware" do |app|
      app.middleware.use(RequestTrail::Middleware)
      Subscriber.attach
    end
    # :nocov:
  end
end
