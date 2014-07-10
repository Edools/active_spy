# encoding: utf-8

module ActiveSpy
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc 'Creates an active_spy gem configuration file at config/active_spy.yml, and an initializer at config/initializers/active_spy.rb'

      def self.source_root
        @_active_spy_source_root ||= File.expand_path("../templates", __FILE__)
      end

      def create_config_file
        template 'active_spy.yml', File.join('config', 'active_spy.yml')
      end

      def create_initializer_file
        template 'initializer.rb', File.join('config', 'initializers', 'active_spy.rb')
      end
    end
  end
end
