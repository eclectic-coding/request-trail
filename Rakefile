# frozen_string_literal: true

require "bundler/gem_tasks"
require "rubocop/rake_task"
require "rspec/core/rake_task"
require "bundler/audit/task"

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)
Bundler::Audit::Task.new

desc "Run bundler-audit, rubocop, and rspec (full CI suite)"
task default: ["bundle:audit:update", "bundle:audit:check", :rubocop, :spec]
