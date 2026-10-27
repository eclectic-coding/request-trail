# frozen_string_literal: true

module RequestTrail
  class Railtie < Rails::Railtie
    # simplecov:disable
    initializer "request_trail.insert_middleware" do |app|
      app.middleware.use(RequestTrail::Middleware)
      Subscriber.attach
    end
    # simplecov:enable
  end
end
