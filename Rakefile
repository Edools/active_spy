# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "active_event"
  gem.homepage = "http://github.com/edools/active_event"
  gem.license = "MIT"
  gem.summary = %Q{Send model events to a server, receive and process them elsewhere}
  gem.description = <<-DESC
    With this gem you can watch your models for events (like create, update,
    delete), send these events to a event-runner instance and it redirect these
    events to other apps that are subscrived for them. This gem also provides
    classes that you can use to process the received events too.
  DESC
  gem.email = "d.camata@gmail.com"
  gem.authors = ["Douglas Camata"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['spec'].execute
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
