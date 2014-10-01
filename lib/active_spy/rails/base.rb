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
        request_params = get_request_params(method)
        ::Rails.logger.info("[SPY] Real method: #{method}")
        ::Rails.logger.info("[SPY] Request params: #{request_params}")
        @event_json = { event: request_params }.to_json
        ActiveSpy::Rails::Validation::Event.new(@event_json).validate! unless ActiveSpy::Configuration.skip_validations
        after_callback = "after_#{request_params[:action]}"
        send(after_callback) if respond_to? after_callback
        remove_is_new_method(@object)
      end

      def after_create
        send_event_request unless ActiveSpy::Configuration.development_mode
      end

      def after_update
        send_event_request unless ActiveSpy::Configuration.development_mode
      end

      def after_destroy
        send_event_request unless ActiveSpy::Configuration.development_mode
      end

      # Sends the event request to the configured event-runner instance.
      #
      def send_event_request
        host = ActiveSpy::Configuration.event_host
        port = ActiveSpy::Configuration.event_port
        ::Rails.logger.info("[SPY] Event JSON: #{@event_json}")
        ::Rails.logger.info("[SPY] Object: #{@object.inspect}")
        ::Rails.logger.info("[SPY] Actor: #{@object.instance_variable_get('@actor')}")
        ::Rails.logger.info("[SPY] Realm: #{@object.instance_variable_get('@realm')}")
        begin
          response = RestClient.post "#{host}:#{port}/events", @event_json,
            content_type: :json
        rescue => e
          ::Rails.logger.info(e.response)
        end
        if defined?(Rails) && !ActiveSpy::Configuration.development_mode
          ::Rails.logger.info('[SPY] Event sent to event-runner.')
          ::Rails.logger.info("[SPY] Event-runner response code: #{response.code}")
          ::Rails.logger.info("[SPY] Event-runner response: #{response.body}")
        end
      end

      # Get the event request params for a given +method+.
      #
      def get_request_params(method)
        real_method = method.to_s.split('_').last
        ::Rails.logger.info("[SPY] Method and realm method: #{method} - #{real_method}")
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
