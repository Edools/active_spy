# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see
  # http://guides.rubygems.org/specification-reference/ for more options
  gem.name = 'active_spy'
  gem.homepage = 'http://github.com/edools/active_spy'
  gem.license = 'MIT'
  gem.summary = <<-SUMMARY
    Watch for a method call in any class and run before/after callbacks.
    Has good integration with Rails.
  SUMMARY
  gem.description = <<-DESC
    Watch for a method call in any class and run before/after callbacks.
    You can even watch your Rails models for events (like create, update,
    destroy), send these events to a event-runner instance and it redirect these
    events to other apps that are subscrived for them. This gem also provides
    classes that you can use to process the received events too.
  DESC
  gem.email = 'd.camata@gmail.com'
  gem.authors = ['Douglas Camata']
  gem.files = Dir['lib/**/*'] + Dir['app/**/*.rb'] + Dir['config/**/*.rb'] +
    Dir['.document'] + Dir['README.md'] + Dir['LICENSE.txt'] + Dir['VERSION'] +
    Dir['Rakefile'] + Dir['active_spy.gemspec'] + Dir['Gemfile*']
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/active_spy/**/*_spec.rb']
end

desc 'Code coverage detail'
task :simplecov do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

task default: :spec

require 'yard'
YARD::Rake::YardocTask.new
