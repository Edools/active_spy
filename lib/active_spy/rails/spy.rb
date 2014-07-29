require 'active_support'

module ActiveSpy
  # Module used to hold Rails specific logic.
  #
  module Rails
    # Module that defines methods used to spy on some class methods.
    #
    module Spy
      # Default snippet to extends the class with
      # {ActiveSpy::Spy::ClassMethods} when {ActiveSpy::Spy} is included in
      # it.
      #
      def self.included(base)
        base.extend ClassMethods
      end
      # Class methods to be defined in classes that includes {ActiveSpy::Spy}
      #
      module ClassMethods
        # Class method to define the realm of the model.
        #
        def model_realm(realm_name = nil)
          dynamically_define_method_or_call_block(:realm, realm_name)
        end

        # Class method to define the actor of the model.
        #
        def model_actor(actor_name = nil)
          dynamically_define_method_or_call_block(:actor, actor_name)
        end

        # Defines a method called +method_name+ that will call a method called
        # +method_value+ if a symbol is provided. If a block is provided
        # instead, it will be returned.
        #
        def dynamically_define_method_or_call_block(abstract_name, method_name)
          return unless method_name
          if abstract_name == method_name
            attr_accessor method_name
          else
            define_method method_name do
              send(:instance_variable_get, "@#{abstract_name}")
            end
            define_method "#{method_name}=" do |new_value|
              send(:instance_variable_set, "@#{abstract_name}", new_value)
            end
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
          define_method :payload_for do |_method|
            { self.class.name.downcase.to_sym => attributes }
          end
        end
      end
    end
  end
end
