require 'active_support'

module ActiveEvent
  # Module that defines methods used to spy on some class methods
  #
  module Spy
    # Default snippet to extends the class with {ActiveEvent::Spy::ClassMethods}
    # when {ActiveEvent::Spy} is included in it.
    #
    def self.included(base)
      base.extend ClassMethods
    end

    # Invokes the before callback method on the invoker class
    #
    def invoke_before_callback(method)
      callback_invoker = callback_invoker_class.new(self)
      before_callback = "before_#{method}"
      return unless callback_invoker.respond_to?(before_callback)
      callback_invoker.send(before_callback)
    end

    # Invokes the after callback method on the invoker class
    #
    def invoke_after_callback(method)
      callback_invoker = callback_invoker_class.new(self)
      after_callback = "after_#{method}"
      return unless callback_invoker.respond_to?(after_callback)
      callback_invoker.send(after_callback)
    end

    # Gets the invoker class based on the class' name
    #
    def callback_invoker_class
      ActiveSupport::Inflector.constantize "#{self.class.name}Events"
    end

    # Class methods to be defined in classes that includes {ActiveEvent::Spy}
    #
    module ClassMethods
      # Set watchers for the {method}
      #
      def watch_method(method)
        patch(method)
      end

      private

      # This method patches the {method} in the included class to invoke the
      # callbacks defined in the respective class, that should be named using
      # appending 'Events' to the class' name, and inherites from
      # ActiveEvent::Base.
      #
      def patch(method)
        old_method = instance_method(method)
        define_method method do
          send(:invoke_before_callback, method)
          old_method.bind(self).call
          send(:invoke_after_callback, method)
        end
      end
    end
  end
end
