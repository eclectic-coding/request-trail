# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in request-trail.gemspec
gemspec

gem "irb"
gem "rake", "~> 13.0"

gem "rspec", "~> 3.0"

gem "rubocop", "~> 1.21"
gem "rubocop-rake"

gem "bundler-audit"

gem "activesupport"
gem "rack"
gem "railties"

group :test do
  gem "puma"
  gem "rails", ">= 7.0"
  gem "rspec-rails"
  gem "simplecov", require: false
  gem "simplecov_json_formatter", require: false
end
