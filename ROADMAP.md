# Roadmap

`request_trail` traces a Rails request through every processing layer — middleware, controller, ActiveRecord, cache — and emits a flame-graph-style summary to the log. This roadmap describes the incremental path to a stable 1.0.0.

## 0.4.0 — Flame Graph Output

- Indented ASCII flame-graph renderer with proportional timing bars
- Optional ANSI colour with automatic TTY detection
- Ships as `Request::Trail::Formatters::FlameGraph` alongside the existing plain-text formatter:
  ```
  [RequestTrail] GET /orders 142ms ████████████████████████████████████
    middleware   4ms  █
    controller 100ms  ████████████████████████
      sql       38ms    █████████
      cache      2ms
      view      22ms    █████
  ```

## 0.5.0 — Filtering & Sampling

- Path filters: skip tracing for `/assets`, `/health`, or custom regex patterns
- Slow-request mode: only emit summaries above `threshold_ms`
- Sampling: trace only N% of requests (useful in production)
- Custom formatter API: `config.formatter = MyFormatter`
- Rails generator to scaffold the config initializer (`rails generate request_trail:install`)

## 0.6.0 — Structured Output & Integrations

- JSON formatter for log aggregators (Datadog, Splunk, etc.)
- `config.logger` override for writing to a separate file or custom appender
- Rails log tags integration
- Optional Sidekiq adapter for tracing background job execution layers

## 1.0.0 — Stable Release

- Frozen public API (`Request::Trail.configure`, middleware interface, formatter interface)
- 100% test coverage
- Overhead benchmark suite (target: < 1ms added latency per request)
- Full usage documentation with real-world examples
