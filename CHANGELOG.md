## [Unreleased]

### Added

- `config.ignore_paths` — skip tracing for specific paths; accepts strings (exact match) or regexes (e.g. `["/health", /^\/assets/]`)
- `config.sample_rate` — trace only N% of requests; accepts a float between `0.0` and `1.0` (default `1.0` = 100%)
- `RequestTrail::Formatters::Base` — mixin that documents the formatter duck-type contract; include it in custom formatters and implement `#format(request, collector) -> String`
- `FlameGraph` colour overrides — pass `colors: { controller: "\e[36m" }` to `FlameGraph.new` to replace per-layer ANSI codes; unspecified layers keep their defaults

## [0.4.0] - 2026-06-12

### Added

- `RequestTrail::Formatters::FlameGraph` — opt-in ASCII flame-graph formatter with proportional `█` bars and per-layer ANSI colour (auto-detected via TTY)
- Opt in via `config.formatter = RequestTrail::Formatters::FlameGraph.new`

## [0.3.0] - 2026-06-12

### Added

- Controller and view tracing via `process_action.action_controller` — records total controller duration and view runtime per request
- Formatter switches to tiered multi-line output when controller data is present:
  ```
  [RequestTrail] GET /orders 142ms
    controller  104ms
      sql        38ms (7 queries)
      cache       2ms (4 hits, 1 miss)
      view       22ms
  ```

## [0.2.0] - 2026-06-11

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

[Unreleased]: https://github.com/eclectic-coding/request-trail/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/eclectic-coding/request-trail/releases/tag/v0.4.0
[0.3.0]: https://github.com/eclectic-coding/request-trail/releases/tag/v0.3.0
[0.2.0]: https://github.com/eclectic-coding/request-trail/releases/tag/v0.2.0
[0.1.0]: https://github.com/eclectic-coding/request-trail/releases/tag/v0.1.0
