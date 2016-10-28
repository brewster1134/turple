notification :terminal_notifier, subtitle: 'Turple'

guard :bundler do
  watch 'Gemfile'
end

guard :rubocop, all_on_start: false, cli: '-D' do
  watch(/(.+\.rb)$/)                  { |m| m[0] }
  watch(%r{(?:.+/)?\.rubocop\.yml$})  { |m| File.dirname(m[0]) }
end

guard :rspec, cmd: 'bundle exec rspec --color --format d' do
  watch(%r{^spec/lib/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})       { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')    { 'spec' }
end
