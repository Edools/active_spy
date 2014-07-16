# encoding: utf-8

module ActiveSpy
  # Module that holds the rails generators
  #
  module Generators
    # The generator that installs the gem
    #
    class InstallGenerator < ::Rails::Generators::Base
      desc 'Creates an active_spy gem configuration file at config/active_spy.yml, and inject configurations at config/environment.rb'

      # The source for templates
      #
      def self.source_root
        @@_active_spy_source_root ||= File.expand_path("../templates", __FILE__)
      end

      # Creates a config file based in the +active_spy.yml+ file.
      #
      def create_config_file
        template 'active_spy.yml', File.join('config', 'active_spy.yml')
      end

      # Injects the {ActiveSpy} initialization in the environment.
      #
      def inject_config_into_environment
        content = File.read(File.join(@@_active_spy_source_root, 'initializer.rb'))

        File.open("config/environment.rb", "a+") do |f|
          f << content unless f.read.include?(content)
        end
      end

      # Mount {ActiveSpy::Engine} in the route file.
      #
      def mount_engine
        route "mount ActiveSpy::Engine => 'active_spy', as: :active_spy"
      end
    end
  end
end
