# encoding: utf-8

module ActiveEvent
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc 'Creates an active_event gem configuration file at config/active_event.yml, and an initializer at config/initializers/active_event.rb'

      def self.source_root
        @_active_event_source_root ||= File.expand_path("../templates", __FILE__)
      end

      def create_config_file
        template 'active_event.yml', File.join('config', 'active_event.yml')
      end

      def create_initializer_file
        template 'initializer.rb', File.join('config', 'initializers', 'active_event.rb')
      end
    end
  end
end
