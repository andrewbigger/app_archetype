lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'app_archetype/version'

Gem::Specification.new do |spec|
  spec.name          = 'app_archetype'
  spec.version       = AppArchetype::VERSION
  spec.authors       = ['Andrew Bigger']
  spec.email         = ['andrew.bigger@gmail.com']
  spec.summary       = 'Code project template renderer'
  spec.homepage      = 'https://github.com/andrewbigger/app_archetype'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'cli-format'
  spec.add_dependency 'hashie'
  spec.add_dependency 'highline'
  spec.add_dependency 'json'
  spec.add_dependency 'jsonnet'
  spec.add_dependency 'json-schema'
  spec.add_dependency 'logger'
  spec.add_dependency 'os'
  spec.add_dependency 'ostruct'
  spec.add_dependency 'ruby-handlebars'
  spec.add_dependency 'thor'
  spec.add_dependency 'tty-prompt'
  spec.add_dependency 'tty-table'

  spec.add_development_dependency 'bump'
  spec.add_development_dependency 'private_gem'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubycritic'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
end
