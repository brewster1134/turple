$:.push File.expand_path('../lib', __FILE__)
require 'date'
require 'turple/version'

Gem::Specification.new do |s|
  s.name        = 'turple'
  s.version     = Turple::VERSION
  s.authors     = ['Ryan Brewster']
  s.email       = ['brewster1134+turple@gmail.com']
  s.date        = Date.today.to_s
  s.files       = Dir['{bin,lib}/**/*', 'README.md']
  s.homepage    = 'https://github.com/brewster1134/bumper'
  s.licenses    = ['MIT']
  s.summary     = 'Highly customizable template interpolation'
  s.executables = ['turple']

  s.required_ruby_version = '>= 2.0.0-p247'

  # s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'cli_miami', '~> 1.0.6.pre'
  s.add_runtime_dependency 'i18n'
  s.add_runtime_dependency 'recursive-open-struct'
  # s.add_runtime_dependency 'sourcerer_'
  s.add_runtime_dependency 'thor'

  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-bundler'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'terminal-notifier'
  s.add_development_dependency 'terminal-notifier-guard'
  s.add_development_dependency 'yard'
end
