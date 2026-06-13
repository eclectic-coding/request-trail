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
- [Custom formatters](#custom-formatters)
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
- `collector` — a `RequestTrail::Collector` exposing `elapsed_ms`, `sql_count`, `sql_duration_ms`, `cache_hits`, `cache_misses`, `cache_duration_ms`, `action_duration_ms`, and `view_duration_ms`

### Configuration

Add an initializer to customize behavior:

```ruby
# config/initializers/request_trail.rb
RequestTrail.configure do |config|
  config.enabled       = true      # set to false to disable entirely
  config.log_level     = :info     # Rails logger level (:debug, :info, :warn)
  config.threshold_ms  = 200       # only log requests slower than this (0 = log all)
  config.logger        = nil       # defaults to Rails.logger
  config.formatter     = RequestTrail::Formatters::FlameGraph.new  # optional

  # skip tracing for specific paths (strings = exact match, regexes = pattern match)
  config.ignore_paths  = ["/health", "/up", /^\/assets/]

  # trace only N% of requests — useful in high-traffic production environments
  config.sample_rate   = 0.1      # 0.0 = never, 1.0 = always (default)
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

Bug reports and pull requests are welcome on GitHub at https://github.com/eclectic-coding/request-trail.

[Back to top](#requesttrail)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[Back to top](#requesttrail)