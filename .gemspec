# coding: utf-8
Gem::Specification.new do |s|
  s.author = 'Ryan Brewster'
  s.date = '2014-12-23'
  s.email = 'brewster1134@gmail.com'
  s.files = ["Gemfile", "Gemfile.lock", "Guardfile", "README.md", "bin/turple", "lib/turple.rb", "lib/turple/cli.rb", "lib/turple/data.rb", "lib/turple/interpolate.rb", "lib/turple/template.rb", "yuyi_menu", ".gitignore", ".rspec", ".travis.yml"]
  s.homepage = 'https://github.com/brewster1134/turple'
  s.license = 'MIT'
  s.name = 'turple'
  s.summary = 'Quick Project Templating'
  s.version = '0.0.2'
  s.executables = ["turple"]
  s.add_runtime_dependency 'activesupport', '~> 4.1'
  s.add_runtime_dependency 'cli_miami', '~> 0.0'
  s.add_runtime_dependency 'colorize', '~> 0.7'
  s.add_runtime_dependency 'coveralls', '~> 0.7'
  s.add_runtime_dependency 'recursive-open-struct', '~> 0.5'
  s.add_runtime_dependency 'thor', '~> 0.19'
  s.add_development_dependency 'guard', '~> 2.6'
  s.add_development_dependency 'guard-rspec', '~> 4.3'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'terminal-notifier-guard', '~> 1.5'
end
