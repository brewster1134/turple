# coding: utf-8
$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'date'
require 'turple/version'

Gem::Specification.new do |s|
  s.author      = 'Ryan Brewster'
  s.date        = Date.today.to_s
  s.email       = 'brewster1134@gmail.com'
  s.executables = ['turple']
  s.files       = Dir['{bin,i18n,lib}/**/*', 'README.md']
  s.homepage    = 'https://github.com/brewster1134/turple'
  s.license     = 'WTFPL'
  s.name        = 'turple'
  s.summary     = 'Highly customizable template interpolation'
  s.test_files  = Dir['spec/**/*']
  s.version     = Turple::VERSION

  s.required_ruby_version = Gem::Requirement.new '>= 2.0.0-p247'

  s.add_runtime_dependency 'activesupport', '4.2.7.1'
  s.add_runtime_dependency 'cli_miami', '~> 1.0.6.pre'
  s.add_runtime_dependency 'i18n'
  s.add_runtime_dependency 'recursive-open-struct'
  s.add_runtime_dependency 'thor'

  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-bundler'
  s.add_development_dependency 'guard-rubocop'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'listen', '3.0.8'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'ruby_dep', '1.3.1'
  s.add_development_dependency 'terminal-notifier'
  s.add_development_dependency 'terminal-notifier-guard'
  s.add_development_dependency 'yard'
end
