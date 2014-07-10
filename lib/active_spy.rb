require 'active_spy/configuration'
require 'active_spy/base'
require 'active_spy/spy/spy'
require 'active_spy/spy/spy_list'
require 'active_spy/rails/base' if defined?(Rails)
require 'active_spy/rails/spy' if defined?(Rails)
require 'active_spy/rails/railtie' if defined?(Rails)
require 'active_spy/rails/engine' if defined?(Rails)
require 'active_spy/rails/engine' if defined?(Rails)
require 'active_spy/rails/hook_list' if defined?(Rails)
require 'active_spy/rails/listener'

# Base module for the gem
#
module ActiveSpy
  if defined?(Rails)
    # @!method self.configure
    # Class method to set the service's name, host and port.
    #
    def self.configure
      Configuration.instance_eval do
        yield(self)
      end
    end

    # @!method self.register_service
    # Class method to register the service in an event-runner instance.
    #
    def self.register_service
      host = ActiveSpy::Configuration.event_host
      port = ActiveSpy::Configuration.event_port
      @@base_url = "#{host}:#{port}/services"

      return if self.service_registered?
      RestClient.post @@base_url, service: ActiveSpy::Configuration.settings
    end

    # @!method self.service_registered?
    # Check if the service was already registetered in the configured event
    # runner instance.
    #
    def self.service_registered?
      name = ActiveSpy::Configuration.name
      r = RestClient.get "#{@@base_url}/#{name.downcase.gsub(' ', '-').strip}"
      r.code == 200
    end
  end
end
