# frozen_string_literal: true

require 'simplecov'
require 'pry'
require 'bundler/setup'

SimpleCov.start

SimpleCov.configure do
  add_filter 'config'
  add_filter 'spec'
  add_filter 'vendor'
  coverage_dir 'target/reports/coverage'
  minimum_coverage 10
end

require 'app_archetype'
require 'app_archetype/cli'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
