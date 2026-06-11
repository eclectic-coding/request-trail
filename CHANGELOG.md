## [Unreleased]

### Added

- Cache tracing via `cache_read.active_support` and `cache_write.active_support` notifications — records hit/miss/write counts and cumulative duration per request
- Summary line now includes a cache segment: `[RequestTrail] GET /orders 142ms | SQL: 7/38.3ms | Cache: 4 hits, 1 miss, 2.0ms`

## [0.1.0] - 2026-06-11

### Added

- Rack middleware (`RequestTrail::Middleware`) that wraps requests and records wall-clock duration
- Rails Railtie (`RequestTrail::Railtie`) for automatic middleware insertion
- ActiveRecord query tracing via `sql.active_record` notifications — records query count and cumulative duration per request
- Configuration DSL: `RequestTrail.configure { |c| c.enabled = true; c.log_level = :info; c.threshold_ms = 0; c.logger = nil }`
- Plain-text log formatter producing summaries like `[RequestTrail] GET /orders 142ms | SQL: 7 queries / 38ms`
- `RequestTrail::Subscriber` — attach/detach API for notification subscriptions
- `RequestTrail::Collector` — thread-safe per-request event accumulator

[Unreleased]: https://github.com/eclectic-coding/request-trail/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/eclectic-coding/request-trail/releases/tag/v0.1.0
