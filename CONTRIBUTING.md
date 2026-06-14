# Contributing to RequestTrail

Bug reports and pull requests are welcome on GitHub at https://github.com/eclectic-coding/request-trail.

## Getting started

```bash
git clone https://github.com/eclectic-coding/request-trail.git
cd request-trail
bin/setup
```

## Development workflow

Run the full CI suite before opening a pull request:

```bash
bundle exec rake          # lint + security audit + tests
bundle exec rake spec     # tests only
bundle exec rake rubocop  # lint only
bundle exec rake rubocop:autocorrect  # auto-fix correctable offenses
```

All of the following must pass:

- **RuboCop** — no offenses (`bundle exec rake rubocop`)
- **bundler-audit** — no known vulnerabilities (`bundle exec rake bundle:audit:check`)
- **RSpec** — all examples pass with 100% line coverage (`bundle exec rake spec`)

You can also run a single spec file or example:

```bash
bundle exec rspec spec/request_trail/collector_spec.rb
bundle exec rspec spec/request_trail/collector_spec.rb:42
```

## Code style

- Ruby 3.3+ syntax; all new cops enabled via `NewCops: enable`
- Double-quoted strings throughout
- `# frozen_string_literal: true` on every file
- No doc comments on internal classes (`Style/Documentation` is disabled)
- Comments only when the *why* is non-obvious — avoid restating what the code does

## Pull requests

1. Fork the repo and create a branch from `main` (`feat/`, `fix/`, `docs/` prefixes work well)
2. Make your changes with tests — coverage must remain at 100%
3. Run `bundle exec rake` and fix any failures
4. Open a PR against `main` with a clear description of what and why

Small, focused PRs are easier to review than large ones. If you are planning a significant change, open an issue first to discuss the approach.

## Reporting bugs

Please include:

- Ruby version (`ruby --version`)
- Rails / Rack version
- A minimal reproduction script or failing spec
- The log output you expected vs. what you actually saw

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE.txt).