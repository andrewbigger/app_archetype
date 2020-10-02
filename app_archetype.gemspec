lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'app_archetype/version'

Gem::Specification.new do |spec|
  spec.name          = 'app_archetype'
  spec.version       = AppArchetype::VERSION
  spec.authors       = ['Andrew Bigger']
  spec.email         = ['andrew@biggerconcept.com']
  spec.summary       = 'Code project template renderer'
  spec.homepage      = 'https://bitbucket.org/biggerconcept/app_archetype'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'cli-format', '~> 0.2'
  spec.add_dependency 'highline', '~> 2.0'
  spec.add_dependency 'json', '~> 2.3'
  spec.add_dependency 'jsonnet', '~> 0.3.0'
  spec.add_dependency 'json-schema', '~> 2.8'
  spec.add_dependency 'logger', '~> 1.4.2'
  spec.add_dependency 'os', '~> 1.1'
  spec.add_dependency 'ostruct', '~> 0.3'
  spec.add_dependency 'ruby-handlebars', '~> 0.4'
  spec.add_dependency 'thor', '~> 1.0'

  spec.add_development_dependency 'bump', '~> 0.9'
  spec.add_development_dependency 'private_gem', '~> 1.1'
  spec.add_development_dependency 'pry', '~> 0.13'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 0.92'
  spec.add_development_dependency 'rubycritic', '~> 4.5'
  spec.add_development_dependency 'simplecov', '~> 0.19'
  spec.add_development_dependency 'yard', '~> 0.9'
end
