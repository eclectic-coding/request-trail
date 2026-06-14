# frozen_string_literal: true

# Measures the per-request overhead added by RequestTrail::Middleware.
#
# Run with:
#   bundle exec ruby benchmarks/overhead.rb
#
# Target: < 1ms added latency per request.

require "benchmark/ips"
require "rack"
require "rack/mock"
require "active_support"
require "active_support/notifications"
require_relative "../lib/request_trail"

INNER_APP = ->(_env) { [200, { "content-type" => "text/plain" }, ["OK"]] }

RequestTrail.configure do |config|
  config.enabled    = true
  config.log_level  = :debug
  config.logger     = Logger.new(File::NULL)
  config.threshold_ms = 0
end

RequestTrail::Subscriber.attach

TRACED_APP = RequestTrail::Middleware.new(INNER_APP)

ENV_TEMPLATE = Rack::MockRequest.env_for("/bench", method: "GET")

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("baseline (no middleware)") do
    INNER_APP.call(ENV_TEMPLATE.dup)
  end

  x.report("with RequestTrail middleware") do
    TRACED_APP.call(ENV_TEMPLATE.dup)
  end

  x.compare!
end

# Print overhead summary using monotonic clock (no benchmark gem required)
n = 50_000

t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
n.times { INNER_APP.call(ENV_TEMPLATE.dup) }
baseline_s = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0

t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
n.times { TRACED_APP.call(ENV_TEMPLATE.dup) }
traced_s = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0

overhead_ms = ((traced_s - baseline_s) / n) * 1000

puts format("\n-- Overhead summary (%d iterations) --", n)
puts format("Baseline:    %.3f µs/req", (baseline_s / n) * 1_000_000)
puts format("Traced:      %.3f µs/req", (traced_s   / n) * 1_000_000)
puts format("Overhead:    %.4f ms/req (target: < 1ms)", overhead_ms)
puts overhead_ms < 1.0 ? "PASS: overhead is under 1ms" : "FAIL: overhead exceeds 1ms"
