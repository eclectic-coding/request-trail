RequestTrail.configure do |config|
  config.enabled   = true
  config.log_level = :info
  config.logger    = Logger.new($stdout)
  config.formatter = RequestTrail::Formatters::FlameGraph.new(colorize: true)
end