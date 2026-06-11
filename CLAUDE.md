# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`request-trail` is a Ruby gem (namespace `Request::Trail`) currently in early development. The scaffold is in place; the core implementation is yet to be written in `lib/request/trail.rb`.

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
  request/
    trail.rb            # Entry point — defines Request::Trail module and Error class
    trail/
      version.rb        # VERSION constant
spec/
  request/
    trail_spec.rb       # Main spec
  spec_helper.rb        # Configures SimpleCov (HTML + JSON), RSpec options
```

## Code Style

- RuboCop targets Ruby 3.3; `NewCops: enable` means all new cops are active
- String literals must use **double quotes** (both regular strings and interpolation)
- `spec/**/*` is excluded from RuboCop — no need to add cops there
- All files use `# frozen_string_literal: true`

## CI

The GitHub Actions CI (`.github/workflows/main.yml`) runs three jobs on push/PR:
- **Lint**: RuboCop on Ruby 3.3
- **Security**: bundler-audit
- **Test**: RSpec matrix across Ruby 3.3, 3.4, and 4.0; coverage uploaded to Codecov from the 3.4 run

Releases are triggered by `v*` tags via `.github/workflows/publish.yml`, which verifies the tag matches `VERSION`, runs the full suite, builds the gem, and pushes to RubyGems using trusted publishing.