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

      # Handles the generic +save+. Determines which rail action was done,
      # +create+ or +update+ and call the right callback.
      #
      def after_save
        action = get_action('save')
        send("after_#{action}")
      end

      # Handles a +create+ callback, prepare and send the request to the event-runner.
      #
      def after_create
        request_params = get_request_params('create')
        prepare_request(request_params)
        send_event_request unless ActiveSpy::Configuration.development_mode
      end

      # Handles an +update+ callback, prepare and send the request to the event-runner.
      #
      def after_update
        request_params = get_request_params('update')
        prepare_request(request_params)
        send_event_request unless ActiveSpy::Configuration.development_mode
      end

      # Handles an +destroy+ callback, prepare and send the request to the event-runner.
      #
      def after_destroy
        request_params = get_request_params('destroy')
        prepare_request(request_params)
        send_event_request unless ActiveSpy::Configuration.development_mode
      end

      # Prepare a request with +request_params+, validates the request and
      # remove the injected +is_mew_method+, because it's not needed anymore.
      #
      def prepare_request(request_params)
        @event_json = { event: request_params }.to_json
        ActiveSpy::Rails::Validation::Event.new(@event_json).validate! unless ActiveSpy::Configuration.skip_validations
        remove_is_new_method(@object)
      end

      # Sends the event request to the configured event-runner instance.
      #
      def send_event_request
        host = ActiveSpy::Configuration.event_host
        port = ActiveSpy::Configuration.event_port
        begin
          response = RestClient.post "#{host}:#{port}/events", @event_json,
            content_type: :json
        rescue => e
        end
        if defined?(Rails) && !ActiveSpy::Configuration.development_mode
        end
      end

      # Get the event request params for a given +method+.
      #
      def get_request_params(action)
        # real_method = method.to_s.split('_').last
        # action = get_action(real_method)
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
