# Roadmap

`request_trail` traces a Rails request through every processing layer — middleware, controller, ActiveRecord, cache — and emits a flame-graph-style summary to the log. This roadmap describes the incremental path to a stable 1.0.0.

## 0.5.0 — Filtering & Sampling

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
