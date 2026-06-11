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

RequestTrail auto-inserts itself via a Railtie. No manual middleware configuration is needed — just add the gem to your `Gemfile` and it will log a summary after every request:

```
[RequestTrail] GET /orders 142ms | SQL: 7/38.3ms | Cache: 4 hits, 1 miss, 2.0ms
```

The summary line shows:
- **Total request time** in milliseconds
- **SQL** — query count and cumulative Active Record time
- **Cache** — hit/miss/write counts and cumulative cache time

### Configuration

Add an initializer to customize behavior:

```ruby
# config/initializers/request_trail.rb
RequestTrail.configure do |config|
  config.enabled       = true      # set to false to disable entirely
  config.log_level     = :info     # Rails logger level (:debug, :info, :warn)
  config.threshold_ms  = 200       # only log requests slower than this (0 = log all)
  config.logger        = nil       # defaults to Rails.logger
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

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

[Back to top](#requesttrail)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eclectic-coding/request-trail.

[Back to top](#requesttrail)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[Back to top](#requesttrail)