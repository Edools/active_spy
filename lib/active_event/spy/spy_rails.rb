require 'active_support'

module ActiveEvent
  # Module used to hold Rails specific logic.
  #
  module Rails
    # Module that defines methods used to spy on some class methods.
    #
    module Spy
      # Default snippet to extends the class with
      # {ActiveEvent::Spy::ClassMethods} when {ActiveEvent::Spy} is included in
      # it.
      #
      def self.included(base)
        base.extend ClassMethods
      end
      # Class methods to be defined in classes that includes {ActiveEvent::Spy}
      #
      module ClassMethods
        # Class method to define the realm of the model.
        #
        def model_realm(realm_name = nil, &block)
          realm = -> { send(realm_name) } if realm_name
          realm = block if block_given?
          define_method :realm do
            realm.call
          end
        end

        # Helper to use on Rails app and watch for model creation, update and
        # destruction.
        #
        def watch_model_changes
          watch_method :save, :destroy
          inject_payload_for_method
        end

        # Helper to inject the method +payload_for(method)+ in the model
        # with the default behavior: all attributes are sent in all
        # actions.
        #
        def inject_payload_for_method
          define_method :payload_for do
            { self.class.name.downcase.to_sym => attributes }
          end
        end
      end
    end
  end
end
