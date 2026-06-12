RequestTrail.configure do |config|
  config.enabled   = true
  config.log_level = :info
  config.logger    = Logger.new(Rails.root.join("log/request_trail.log"))
  config.formatter = RequestTrail::Formatters::FlameGraph.new(colorize: false)
end