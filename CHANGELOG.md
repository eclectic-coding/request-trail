## [Unreleased]

### Added

- Rack middleware (`RequestTrail::Middleware`) that wraps requests and records wall-clock duration
- Rails Railtie (`RequestTrail::Railtie`) for automatic middleware insertion
- ActiveRecord query tracing via `sql.active_record` notifications — records query count and cumulative duration per request
- Configuration DSL: `RequestTrail.configure { |c| c.enabled = true; c.log_level = :info; c.threshold_ms = 0; c.logger = nil }`
- Plain-text log formatter producing summaries like `[RequestTrail] GET /orders 142ms | SQL: 7 queries / 38ms`
- `RequestTrail::Subscriber` — attach/detach API for notification subscriptions
- `RequestTrail::Collector` — thread-safe per-request event accumulator

[Unreleased]: https://github.com/eclectic-coding/request-trail/commits/main