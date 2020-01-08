require 'private_gem/tasks'
require 'bundler/gem_tasks'
require 'bump/tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'rubycritic/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

RubyCritic::RakeTask.new do |task|
  task.paths = FileList['lib/**/*.rb'] - FileList['spec/**/*_spec.rb']
  task.options = '--no-browser --path ./target/reports/critique'
end

YARD::Rake::YardocTask.new

task default: %i[spec rubocop rubycritic yard]
