# RequestTrail

[![CI](https://github.com/eclectic-coding/request-trail/actions/workflows/main.yml/badge.svg)](https://github.com/eclectic-coding/request-trail/actions/workflows/main.yml)
[![Gem Version](https://img.shields.io/gem/v/request_trail.svg)](https://rubygems.org/gems/request_trail)
[![Downloads](https://img.shields.io/gem/dt/request_trail.svg)](https://rubygems.org/gems/request_trail)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.3-CC342D.svg)](https://rubygems.org/gems/request_trail)
[![codecov](https://codecov.io/gh/eclectic-coding/request-trail/branch/main/graph/badge.svg)](https://codecov.io/gh/eclectic-coding/request-trail)

Middleware that traces a request through all the layers (middleware, controller, ActiveRecord, cache) and dumps a flame-graph-style summary to the log.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Rails](#rails)
  - [JSON formatter](#json-formatter)
  - [Flame graph formatter](#flame-graph-formatter)
  - [N+1 detection](#n1-detection)
  - [Rails log tags](#rails-log-tags)
  - [Sidekiq](#sidekiq)
  - [ActiveJob](#activejob)
  - [Outbound HTTP tracking](#outbound-http-tracking)
  - [Custom formatters](#custom-formatters)
  - [Installation generator](#installation-generator)
  - [Configuration](#configuration)
  - [Non-Rails (plain Rack)](#non-rails-plain-rack)
- [Stable API](#stable-api)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Installation

Add to your application's Gemfile:

```bash
bundle add request_trail
```

Or install directly:

```bash
gem install request_trail
```

[Back to top](#requesttrail)

## Usage

### Rails

RequestTrail auto-inserts itself via a Railtie. No manual middleware configuration is needed — just add the gem to your `Gemfile` and it will log a summary after every request.

When controller tracing is active, output is tiered:

```
[RequestTrail] GET /orders 142ms
  controller  104ms
    sql        38ms (7 queries)
    cache       2ms (4 hits, 1 miss)
    view       22ms
```

Without controller data (plain Rack apps), a single-line summary is emitted:

```
[RequestTrail] GET /orders 142ms | SQL: 7/38.3ms | Cache: 4 hits, 1 miss, 2.0ms
```

### JSON formatter

Emit structured JSON for log aggregators (Datadog, Splunk, etc.):

```ruby
RequestTrail.configure do |config|
  config.formatter = RequestTrail::Formatters::JSON.new
end
```

Example output (flat request):

```json
{"method":"GET","path":"/orders","duration_ms":142.5,"sql":{"count":7,"duration_ms":38.0},"cache":{"hits":4,"misses":1,"writes":0,"duration_ms":2.0}}
```

When controller data is present a `"controller"` key is added:

```json
{"method":"GET","path":"/orders","duration_ms":142.5,"sql":{"count":7,"duration_ms":38.0},"cache":{"hits":4,"misses":1,"writes":0,"duration_ms":2.0},"controller":{"duration_ms":104.0,"view_duration_ms":22.0}}
```

### Flame graph formatter

Opt into the ASCII flame-graph formatter for a visual proportional breakdown:

```ruby
RequestTrail.configure do |config|
  config.formatter = RequestTrail::Formatters::FlameGraph.new
end
```

Output (with ANSI colour when stdout is a TTY):

```
[RequestTrail] GET /orders 142ms ████████████████████████████████████
  controller   104ms ████████████████████████████
    sql         38ms █████████
    cache        2ms
    view        22ms █████
```

Colour scheme: controller = blue, sql = yellow, cache = green, view = magenta. Plain bars are emitted when stdout is not a TTY (e.g. log files, CI).

Override any layer's ANSI code with the `colors:` option:

```ruby
RequestTrail::Formatters::FlameGraph.new(
  colorize: true,
  colors: { controller: "\e[36m", sql: "\e[31m" }
)
```

Unspecified layers keep their defaults.

### N+1 detection

Set `config.n_plus_one_threshold` to flag requests that fire too many SQL queries. When `sql_count >= threshold`, all formatters add a prominent marker:

```ruby
RequestTrail.configure do |config|
  config.n_plus_one_threshold = 10  # nil = disabled (default)
end
```

Plain text and FlameGraph append `[N+1?]` to the header line:

```
[RequestTrail] GET /orders 142ms [N+1?] | SQL: 15/85.0ms | Cache: 0 hits, 0 misses, 0.0ms
```

JSON includes `"n_plus_one": true` in the payload:

```json
{"method":"GET","path":"/orders","duration_ms":142.5,"n_plus_one":true,"sql":{"count":15,"duration_ms":85.0},...}
```

### Rails log tags

Add `RequestTrail.log_tag` to `config.log_tags` to include live request state on every tagged log line. The callable returns a lazy value that evaluates to `sql=N Nms` at log-line format time — so it reflects the accumulated query state at each point during the request:

```ruby
# config/application.rb
config.log_tags = [:request_id, RequestTrail.log_tag]
```

Example output:

```
[abc-123] [sql=3 25ms] Completed 200 OK in 25ms
[abc-123] [sql=3 25ms] [RequestTrail] GET /orders 25ms | SQL: 3/10.0ms | Cache: 0 hits, 0 misses, 0.0ms
```

The tag is omitted (blank-suppressed by Rails) on lines that fall outside an active request.

### Sidekiq

Add `RequestTrail::SidekiqMiddleware` to the Sidekiq server middleware chain to trace background job execution with the same flame-graph output:

```ruby
# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add RequestTrail::SidekiqMiddleware
  end
end
```

Output uses `JOB` as the method and includes the worker class and job ID:

```
[RequestTrail] JOB HardWorker jid:abc123 42ms | SQL: 5/35.0ms | Cache: 0 hits, 0 misses, 0.0ms
```

All configuration options (`threshold_ms`, `sample_rate`, `n_plus_one_threshold`, `formatter`, etc.) apply to Sidekiq jobs the same way they apply to HTTP requests.

### ActiveJob

Include `RequestTrail::ActiveJobSubscriber` in `ApplicationJob` to trace background jobs across all ActiveJob backends (GoodJob, Solid Queue, DelayedJob, Sidekiq-via-ActiveJob, etc.):

```ruby
# app/jobs/application_job.rb
class ApplicationJob < ActiveJob::Base
  include RequestTrail::ActiveJobSubscriber
end
```

All jobs that inherit from `ApplicationJob` are then automatically traced. Output uses `JOB` as the method and includes the job class and `job_id`:

```
[RequestTrail] JOB OrderSyncJob jid:476b61a6-ae85-4ae8-ae64-bf92e8cfeefc 42ms | SQL: 5/35.0ms | Cache: 0 hits, 0 misses, 0.0ms
```

All configuration options (`threshold_ms`, `sample_rate`, `n_plus_one_threshold`, `formatter`, etc.) apply to ActiveJob jobs the same way they apply to HTTP requests.

**`ActiveJobSubscriber` vs `SidekiqMiddleware`:** Use `ActiveJobSubscriber` when you want adapter-agnostic tracing via `ApplicationJob` inheritance. Use `SidekiqMiddleware` when running Sidekiq workers that do *not* go through ActiveJob (i.e., plain `Sidekiq::Worker` classes).

### Outbound HTTP tracking

Outbound HTTP calls made via Faraday are tracked automatically once `Subscriber.attach` is called (which happens via the Railtie in Rails apps). No additional configuration is needed — the `request.faraday` notification is subscribed alongside SQL and cache events.

Plain text output includes an `HTTP` segment:

```
[RequestTrail] GET /orders 142ms | SQL: 7/38.3ms | Cache: 4 hits, 1 miss, 2.0ms | HTTP: 2/45.0ms
```

Tiered output adds an `http` row under the controller:

```
[RequestTrail] GET /orders 142ms
  controller  104ms
    sql        38ms (7 queries)
    cache       2ms (4 hits, 1 miss)
    view       22ms
    http       45ms (2 calls)
```

JSON output includes an `"http"` key:

```json
{"method":"GET","path":"/orders","duration_ms":142.5,...,"http":{"count":2,"duration_ms":45.0}}
```

### Custom formatters

Any object that responds to `format(request, collector)` and returns a `String` can be used as a formatter. Include `RequestTrail::Formatters::Base` to make the contract explicit:

```ruby
class MyFormatter
  include RequestTrail::Formatters::Base

  def format(request, collector)
    "#{request.request_method} #{request.path} took #{collector.elapsed_ms.round}ms"
  end
end

RequestTrail.configure do |config|
  config.formatter = MyFormatter.new
end
```

`format` receives:
- `request` — a `Rack::Request` with the current HTTP request
- `collector` — a `RequestTrail::Collector` exposing `elapsed_ms`, `sql_count`, `sql_duration_ms`, `cache_hits`, `cache_misses`, `cache_duration_ms`, `action_duration_ms`, `view_duration_ms`, `http_count`, and `http_duration_ms`

### Installation generator

Run the generator to scaffold the initializer:

```bash
rails generate request_trail:install
```

This creates `config/initializers/request_trail.rb` pre-populated with all available options and their defaults.

### Configuration

Add an initializer to customize behavior:

```ruby
# config/initializers/request_trail.rb
RequestTrail.configure do |config|
  config.enabled              = true      # set to false to disable entirely
  config.log_level            = :info     # Rails logger level (:debug, :info, :warn)
  config.threshold_ms         = 200       # only log requests slower than this (0 = log all)
  config.logger               = nil       # defaults to Rails.logger
  config.formatter            = RequestTrail::Formatters::FlameGraph.new  # optional

  # skip tracing for specific paths (strings = exact match, regexes = pattern match)
  config.ignore_paths         = ["/health", "/up", /^\/assets/]

  # trace only N% of requests — useful in high-traffic production environments
  config.sample_rate          = 0.1      # 0.0 = never, 1.0 = always (default)

  # flag requests with too many SQL queries (nil = disabled)
  config.n_plus_one_threshold = 10
end
```

### Non-Rails (plain Rack)

Insert the middleware manually and attach the subscriber:

```ruby
require "request_trail"

RequestTrail::Subscriber.attach

use RequestTrail::Middleware
run MyApp
```

[Back to top](#requesttrail)

## Stable API

As of v1.0.0 the following interfaces are frozen and will not change in a breaking way within the 1.x series:

| Interface | Notes |
|-----------|-------|
| `RequestTrail.configure { \|c\| ... }` | Configuration DSL — all `config.*=` setters |
| `RequestTrail::Middleware` | Rack middleware; constructor signature `Middleware.new(app)` |
| `RequestTrail::Railtie` | Auto-inserted; no public API beyond being present |
| `RequestTrail::Subscriber.attach` / `.detach` | Notification subscription lifecycle |
| `RequestTrail::Collector` attr readers | `elapsed_ms`, `sql_count`, `sql_duration_ms`, `cache_hits`, `cache_misses`, `cache_writes`, `cache_duration_ms`, `action_duration_ms`, `view_duration_ms`, `http_count`, `http_duration_ms` |
| `RequestTrail::Formatters::Base` | Formatter duck-type contract: `#format(request, collector) -> String` |
| `RequestTrail::Formatters::FlameGraph` | Constructor: `FlameGraph.new(colorize:, colors:)` |
| `RequestTrail::Formatters::JSON` | Constructor: `JSON.new` |
| `RequestTrail::SidekiqMiddleware` | Sidekiq server middleware |
| `RequestTrail::ActiveJobSubscriber` | Module to include in `ApplicationJob` |
| `RequestTrail.log_tag` | Returns a proc suitable for `config.log_tags` |

[Back to top](#requesttrail)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake` to run the full CI suite (audit + lint + tests). You can also run `bin/console` for an interactive prompt.

### Running tests

```bash
bundle exec rake spec          # full test suite
bundle exec rspec spec/path/to/file_spec.rb  # single file
bundle exec rspec spec/path/to/file_spec.rb:42  # single example
```

### Dummy app

A minimal Rails app lives in `spec/dummy` for manual end-to-end testing. It mounts a single `GET /ping` endpoint and logs RequestTrail output to `spec/dummy/log/request_trail.log`.

Start the server:

```bash
bundle exec rackup spec/dummy/config.ru --port 3000
```

Then make a request and tail the log:

```bash
curl http://localhost:3000/ping
tail -f spec/dummy/log/request_trail.log
```

You should see tiered output like:

```
[RequestTrail] GET /ping 33ms
  controller  3ms
    sql        0.0ms (0 queries)
    cache      0.0ms (0 hits, 0 misses)
    view       2.8ms
```

[Back to top](#requesttrail)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eclectic-coding/request-trail. See [CONTRIBUTING.md](CONTRIBUTING.md) for setup instructions, code style guidelines, and the pull request workflow.

[Back to top](#requesttrail)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[Back to top](#requesttrail)