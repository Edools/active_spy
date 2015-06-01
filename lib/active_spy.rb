require 'active_spy/configuration'
require 'active_spy/base'
require 'active_spy/spy/spy'
require 'active_spy/spy/spy_list'

if defined?(Rails)
  require 'active_spy/rails/base'
  require 'active_spy/rails/spy'
  require 'active_spy/rails/railtie'
  require 'active_spy/rails/engine'
  require 'active_spy/rails/engine'
  require 'active_spy/rails/hook_list'
  require 'active_spy/rails/listener'
  require 'active_spy/rails/validation'
end

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
      host        = ActiveSpy::Configuration.event_host
      port        = ActiveSpy::Configuration.event_port
      verify_ssl  = ActiveSpy::Configuration.event_verify_ssl
      @base_url   = "#{host}:#{port}/services"

      return if self.service_registered?
      service = { service: ActiveSpy::Configuration.settings }.to_json

      params = { content_type: :json, method: :post, url: @base_url, payload: service }
      params[:verify_ssl] = verify_ssl if verify_ssl

      RestClient::Request.execute(params)
    end

    # @!method self.service_registered?
    # Check if the service was already registetered in the configured event
    # runner instance.
    #
    def self.service_registered?
      name        = ActiveSpy::Configuration.name
      verify_ssl  = ActiveSpy::Configuration.event_verify_ssl
      url         = "#{@base_url}/#{name.downcase.gsub(' ', '-').strip}"

      begin
        if verify_ssl
          RestClient::Request.execute(method: :get, url: url, verify_ssl: verify_ssl)
        else
          RestClient.get url
        end
      rescue RestClient::ResourceNotFound
        return false
      else
        return true
      end
    end
  end
end
