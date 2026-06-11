# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`request_trail` is a Ruby gem (module `RequestTrail`) that traces a Rails request through all processing layers and dumps a flame-graph-style summary to the log.

## Commands

```bash
bin/setup               # Install dependencies
bundle exec rake        # Full CI suite: bundler-audit + rubocop + rspec (default task)
bundle exec rake spec   # Run tests only
bundle exec rake rubocop # Lint only
bundle exec rake rubocop:autocorrect # Auto-fix lint violations
bundle exec rake bundle:audit:update bundle:audit:check # Security audit
bundle exec rspec spec/path/to/file_spec.rb # Run a single spec file
bundle exec rspec spec/path/to/file_spec.rb:42 # Run a single example by line
bin/console             # Interactive prompt with gem loaded
```

## Architecture

```
lib/
  request_trail.rb          # Entry point — RequestTrail module, configure/formatter/reset!
  request_trail/
    version.rb              # VERSION constant
    configuration.rb        # Config object (enabled, log_level, threshold_ms, logger)
    collector.rb            # Per-request event accumulator (Thread.current storage)
    subscriber.rb           # ActiveSupport::Notifications subscriber for sql.active_record
    formatter.rb            # Plain-text log formatter
    middleware.rb           # Rack middleware — wraps request, drives collector lifecycle
    railtie.rb              # Rails Railtie — auto-inserts middleware, attaches subscriber
spec/
  request_trail_spec.rb     # Main module spec
  request_trail/            # Per-class specs
  spec_helper.rb            # Configures SimpleCov (HTML + JSON), loads rack/activesupport/railties
```

## Code Style

- RuboCop targets Ruby 3.3; `NewCops: enable` means all new cops are active
- String literals must use **double quotes** (both regular strings and interpolation)
- `spec/**/*` and `vendor/**/*` are excluded from RuboCop
- All files use `# frozen_string_literal: true`
- `Style/Documentation` is disabled — internal classes do not require doc comments

## CI

The GitHub Actions CI (`.github/workflows/main.yml`) runs three jobs on push/PR:
- **Lint**: RuboCop on Ruby 3.3
- **Security**: bundler-audit
- **Test**: RSpec matrix across Ruby 3.3, 3.4, and 4.0; coverage uploaded to Codecov from the 3.4 run

Releases are triggered by `v*` tags via `.github/workflows/publish.yml`, which verifies the tag matches `VERSION`, runs the full suite, builds the gem, and pushes to RubyGems using trusted publishing.