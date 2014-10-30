# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: active_spy 1.3.12 ruby lib

Gem::Specification.new do |s|
  s.name = "active_spy"
  s.version = "1.3.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Douglas Camata"]
  s.date = "2014-10-30"
  s.description = "    Watch for a method call in any class and run before/after callbacks.\n    You can even watch your Rails models for events (like create, update,\n    destroy), send these events to a event-runner instance and it redirect these\n    events to other apps that are subscrived for them. This gem also provides\n    classes that you can use to process the received events too.\n"
  s.email = "d.camata@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "active_spy.gemspec",
    "app/controllers/active_spy/notifications_controller.rb",
    "config/initializers/active_spy_configuration_loader.rb",
    "config/routes.rb",
    "lib/active_spy.rb",
    "lib/active_spy/base.rb",
    "lib/active_spy/configuration.rb",
    "lib/active_spy/rails/base.rb",
    "lib/active_spy/rails/engine.rb",
    "lib/active_spy/rails/hook_list.rb",
    "lib/active_spy/rails/listener.rb",
    "lib/active_spy/rails/railtie.rb",
    "lib/active_spy/rails/spy.rb",
    "lib/active_spy/rails/validation.rb",
    "lib/active_spy/spy/spy.rb",
    "lib/active_spy/spy/spy_list.rb",
    "lib/rails/generators/active_spy/install/install_generator.rb",
    "lib/rails/generators/active_spy/install/templates/active_spy.yml",
    "lib/rails/generators/active_spy/install/templates/initializer.rb"
  ]
  s.homepage = "http://github.com/edools/active_spy"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Watch for a method call in any class and run before/after callbacks. Has good integration with Rails."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 4.0.0"])
      s.add_runtime_dependency(%q<rest-client>, ["~> 1.6.7"])
      s.add_runtime_dependency(%q<hashie>, [">= 0"])
      s.add_development_dependency(%q<activerecord>, [">= 4.0.0"])
      s.add_development_dependency(%q<rails>, [">= 4.0.0"])
      s.add_development_dependency(%q<rubocop>, ["~> 0.24.0"])
      s.add_development_dependency(%q<pry>, ["~> 0.10.0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0.0"])
      s.add_development_dependency(%q<yard>, ["= 0.8.7.4"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.1.1"])
      s.add_development_dependency(%q<bundler>, ["~> 1.6.3"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 4.0.0"])
      s.add_dependency(%q<rest-client>, ["~> 1.6.7"])
      s.add_dependency(%q<hashie>, [">= 0"])
      s.add_dependency(%q<activerecord>, [">= 4.0.0"])
      s.add_dependency(%q<rails>, [">= 4.0.0"])
      s.add_dependency(%q<rubocop>, ["~> 0.24.0"])
      s.add_dependency(%q<pry>, ["~> 0.10.0"])
      s.add_dependency(%q<rspec>, ["~> 3.0.0"])
      s.add_dependency(%q<yard>, ["= 0.8.7.4"])
      s.add_dependency(%q<rdoc>, ["~> 4.1.1"])
      s.add_dependency(%q<bundler>, ["~> 1.6.3"])
      s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 4.0.0"])
    s.add_dependency(%q<rest-client>, ["~> 1.6.7"])
    s.add_dependency(%q<hashie>, [">= 0"])
    s.add_dependency(%q<activerecord>, [">= 4.0.0"])
    s.add_dependency(%q<rails>, [">= 4.0.0"])
    s.add_dependency(%q<rubocop>, ["~> 0.24.0"])
    s.add_dependency(%q<pry>, ["~> 0.10.0"])
    s.add_dependency(%q<rspec>, ["~> 3.0.0"])
    s.add_dependency(%q<yard>, ["= 0.8.7.4"])
    s.add_dependency(%q<rdoc>, ["~> 4.1.1"])
    s.add_dependency(%q<bundler>, ["~> 1.6.3"])
    s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end

