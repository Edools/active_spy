require 'rest-client'
require 'singleton'
require 'json'

module ActiveSpy
  # Module to hold Rails specific classes and helpers.
  #
  module Rails
    # Default template for callbacks handlers.
    #
    class Base
      def initialize(object)
        @object = object
        inject_is_new_method(@object)
        @object.is_new = true if @object.new_record?
      end

      # Overriding to avoid sending the object to server 2 times (in both
      # before and after callabcks).
      #
      def respond_to?(method)
        method.include?('after_')
      end

      # Inject an attribute in the +object+, called +is_new?+ and a setter
      # for it.
      #
      def inject_is_new_method(object)
        object.instance_eval do
          def is_new=(value)
            @is_new = value
          end

          def is_new?
            @is_new
          end
        end
      end

      # Overriding to always send the object to the server, even though the
      # after callback is not explicitly defined.
      #
      def method_missing(method, *_args, &_block)
        event_json = { event: get_request_params(method) }.to_json
        ActiveSpy::Rails::Validation::Event.new(event_json).validate!
        send_event_request(event_json) if !ActiveSpy::Configuration.development_mode
        remove_is_new_method(@object)
      end

      # Sends the event request to the configured event-runner instance.
      #
      def send_event_request(event_json)
        host = ActiveSpy::Configuration.event_host
        port = ActiveSpy::Configuration.event_port
        RestClient.post "#{host}:#{port}/events", event_json,
          content_type: :json
      end

      # Get the event request params for a given +method+.
      #
      def get_request_params(method)
        real_method = method.to_s.split('_').last
        action = get_action(real_method)
        {
          type:     @object.class.name,
          actor:    @object.instance_variable_get('@actor'),
          realm:    @object.instance_variable_get('@realm'),
          payload:  @object.payload_for(action),
          action:   action
        }
      end

      # Remove a previously added +is_new+ attribute from a given object.
      #
      def remove_is_new_method(object)
        object.instance_eval do
          undef :is_new=
          undef :is_new?
          instance_variable_set(:@is_new, nil)
        end
      end

      # Returns the correct action for the method called in the model.
      #
      def get_action(real_method)
        if real_method == 'save'
          return 'create' if @object.is_new?
          return 'update'
        end
        'destroy'
      end
    end
  end
end
