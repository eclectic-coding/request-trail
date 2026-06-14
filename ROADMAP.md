# Roadmap

`request_trail` traces a Rails request through every processing layer — middleware, controller, ActiveRecord, cache — and emits a flame-graph-style summary to the log. This roadmap describes the incremental path to a stable 1.0.0.

## 0.7.0 — Observability Completeness

- N+1 query detection — flag requests exceeding a configurable `config.n_plus_one_threshold`
- ActiveJob adapter — generic around-perform hook covering GoodJob, Solid Queue, DelayedJob, and Sidekiq-via-ActiveJob
- Outbound HTTP tracking — subscribe to `request.faraday` notifications; surface call count and duration in all formatters

## 1.0.0 — Stable Release

- Frozen public API (`Request::Trail.configure`, middleware interface, formatter interface)
- 100% test coverage
- Overhead benchmark suite (target: < 1ms added latency per request)
- Full usage documentation with real-world examples
