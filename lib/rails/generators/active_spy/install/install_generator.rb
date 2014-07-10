# encoding: utf-8

module ActiveSpy
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc 'Creates an active_spy gem configuration file at config/active_spy.yml, and inject configurations at config/environment.rb'

      def self.source_root
        @@_active_spy_source_root ||= File.expand_path("../templates", __FILE__)
      end

      def create_config_file
        template 'active_spy.yml', File.join('config', 'active_spy.yml')
      end

      def inject_config_into_environment
        content = File.read(File.join(@@_active_spy_source_root, 'initializer.rb'))

        File.open("config/environment.rb", "a+") do |f|
          f << content unless f.read.include?(content)
        end
      end
    end
  end
end
