# coding: utf-8
Gem::Specification.new do |s|
  s.author = 'Ryan Brewster'
  s.date = '2014-11-01'
  s.email = 'brewster1134@gmail.com'
  s.files = ["Gemfile", "Gemfile.lock", "Guardfile", "README.md", "lib/sourcerer.rb", "lib/sourcerer/source_type.rb", "lib/sourcerer/source_types/dir.rb", "lib/sourcerer/source_types/git.rb", "lib/sourcerer/source_types/zip.rb", "yuyi_menu", ".gitignore", ".rspec", ".travis.yml"]
  s.homepage = 'https://github.com/brewster1134/sourcerer'
  s.license = 'MIT'
  s.name = 'sourcerer_'
  s.summary = 'Consume remote sources with ease.'
  s.version = '0.0.4'
  s.add_runtime_dependency 'archive-zip', '~> 0.7.0'
  s.add_runtime_dependency 'git', '~> 1.2.8'
  s.add_runtime_dependency 'rubyzip', '~> 1.1.6'
  s.add_development_dependency 'guard', '~> 2.6.1'
  s.add_development_dependency 'guard-rspec', '~> 4.3.1'
  s.add_development_dependency 'rspec', '~> 3.1.0'
  s.add_development_dependency 'terminal-notifier-guard', '~> 1.5.3'
end
