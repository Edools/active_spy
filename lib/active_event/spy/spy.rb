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

    # Invokes the callback method on the invoker class. The +callback_type+
    # param tells wether it will be called +:after+ or +before+.
    #
    def invoke_callback(method, callback_type)
      callback_invoker = callback_invoker_class.new(self)
      callback = "#{callback_type.to_s}_#{method}"
      return unless callback_invoker.respond_to?(callback)
      callback_invoker.send(callback)
    end

    # Gets the invoker class based on the class' name
    #
    def callback_invoker_class
      ActiveSupport::Inflector.constantize "#{self.class.name}Events"
    end

    # Class methods to be defined in classes that includes {ActiveEvent::Spy}
    #
    module ClassMethods
      # Set watchers for the +method+
      #
      def watch_method(method)
        spy = { 'class' => name, 'method' => method }
        ActiveEvent::SpyList << spy
      end
    end
  end
end
