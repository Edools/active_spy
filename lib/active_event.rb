require 'active_event/configuration'
require 'active_event/base/base'
require 'active_event/base/rails' if defined?(Rails)
require 'active_event/spy/spy'
require 'active_event/spy/spy_list'
require 'active_event/spy/spy_rails' if defined?(Rails)
require 'active_event/railtie' if defined?(Rails)
require 'active_event/listener/listener'

# Base module for the gem
#
module ActiveEvent

  # Class method to register the service in an event-runner instance.
  #
  if defined?(Rails)
    def self.register_service
      host = ActiveEvent::Configuration.event_host
      port = ActiveEvent::Configuration.event_port
      RestClient.post "#{host}:#{port}/services",
        service: ActiveEvent::Configuration.settings
    end
  end
end
