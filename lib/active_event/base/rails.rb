require 'rest-client'

module ActiveEvent
  # Module to hold Rails specific classes and helpers.
  #
  module Rails
    # Default template for callbacks handlers.
    #
    class Base
      def initialize(object)
        @object = object
      end

      # Overriding to avoid sending the object to server 2 times (in both
      # before and after callabcks).
      #
      def respond_to?(method)
        method.include? 'after_'
      end

      # Overriding to always send the object to the server, even though the
      # after callback is not explicitly defined.
      #
      def method_missing(method, *_args, &_block)
        host = ActiveEvent::Configuration.host
        port = ActiveEvent::Configuration.port

        payload = @object.payload_for(method)
        realm = @object.realm
        actor = @object.actor

        real_method = method.to_s.split('_').last

        event_params = {
          type:     real_method,
          actor:    actor,
          realm:    realm,
          payload:  payload
        }

        RestClient.post "#{host}:#{port}", event: event_params
      end
    end
  end
end
