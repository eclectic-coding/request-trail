# frozen_string_literal: true

require_relative "lib/request_trail/version"

Gem::Specification.new do |spec|
  spec.name = "request_trail"
  spec.version = RequestTrail::VERSION
  spec.authors = ["Chuck Smith"]
  spec.email = ["eclectic-coding@users.noreply.github.com"]

  spec.summary = "Traces a Rails request through all layers and dumps a flame-graph summary to the log."
  spec.description = "Middleware that traces a request through middleware, controller, " \
                     "ActiveRecord, and cache layers, then dumps a flame-graph-style summary to the log."
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
