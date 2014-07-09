require 'active_event/configuration'
require 'active_event/base'
require 'active_event/spy/spy'
require 'active_event/spy/spy_list'
require 'active_event/rails/base' if defined?(Rails)
require 'active_event/rails/spy' if defined?(Rails)
require 'active_event/rails/railtie' if defined?(Rails)
require 'active_event/rails/engine' if defined?(Rails)
require 'active_event/rails/engine' if defined?(Rails)
require 'active_event/rails/hook_list' if defined?(Rails)
require 'active_event/rails/listener'

# Base module for the gem
#
module ActiveEvent
  if defined?(Rails)
    # Class method to set the service's name, host and port
    #
    def self.configure
      Configuration.instance_eval do
        yield(self)
      end
    end

    # Class method to register the service in an event-runner instance.
    #
    def self.register_service
      host = ActiveEvent::Configuration.event_host
      port = ActiveEvent::Configuration.event_port
      @@base_url = "#{host}:#{port}/services"

      return if self.service_registered?
      RestClient.post @@base_url, service: ActiveEvent::Configuration.settings
    end

    def self.service_registered?
      name = ActiveEvent::Configuration.name
      r = RestClient.get "#{@@base_url}/#{name.downcase.gsub(' ', '-').strip}"
      r.code == 200
    end
  end
end
