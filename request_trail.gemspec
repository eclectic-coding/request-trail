# frozen_string_literal: true

require_relative "lib/request_trail/version"

Gem::Specification.new do |spec|
  spec.name = "request_trail"
  spec.version = RequestTrail::VERSION
  spec.authors = ["Chuck Smith"]
  spec.email = ["eclectic-coding@users.noreply.github.com"]

  spec.summary = "Per-request flame-graph tracing for Rails: SQL, cache, controller, ActiveJob, and outbound HTTP."
  spec.description = "Rack middleware that traces every request through all processing layers — " \
                     "controller, ActiveRecord, cache, ActiveJob, and outbound HTTP via Faraday — " \
                     "then emits a flame-graph-style summary to the Rails log. " \
                     "Supports plain-text, ASCII flame-graph, and JSON output; " \
                     "N+1 detection; sampling; path filtering; Sidekiq and ActiveJob adapters; " \
                     "and Rails log tags. Overhead under 1ms per request."
  spec.homepage = "https://github.com/eclectic-coding/request-trail"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/eclectic-coding/request-trail"
  spec.metadata["changelog_uri"] = "https://github.com/eclectic-coding/request-trail/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 6.0"
  spec.add_dependency "rack", ">= 2.0"
end
