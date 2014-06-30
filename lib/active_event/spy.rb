require 'active_support'
require 'singleton'

module ActiveEvent
  # Singleton used to hold the spies and lazely active these spies by patching
  # the methods in the specified classes.
  #
  class SpyList
    include Singleton

    # Just to initiliaze the spy list.
    #
    def initialize
      @spies = []
    end

    # Proxy all methods called in the {SpyList} class to call them in
    # {SpyList.instance}. Just a syntax sugar.
    #
    def self.method_missing(method, *args, &block)
      instance.send(method, *args, &block)
    end

    # Active all the spies defined in the spy list by patching the methods
    # in their classes.
    #
    def activate
      @spies.each do |spy|
        spied_class = spy['class']
        spied_method = spy['method']

        patch(spied_class, spied_method)
      end
    end

    # forward {<<} method to the spy list.
    #
    def <<(other)
      @spies << other
    end

    private

    # This method patches the {method} in the class {klass} to invoke the
    # callbacks defined in the respective class, that should be named using
    # appending 'Events' to the class' name, and inherites from
    # ActiveEvent::Base.
    #
    def patch(klass, method)
      ActiveSupport::Inflector.constantize(klass).class_eval do
        old_method = instance_method(method)
        define_method method do
          send(:invoke_before_callback, method)
          old_method.bind(self).call
          send(:invoke_after_callback, method)
        end
      end
    end
  end

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
        spy = { 'class' => name, 'method' => method }
        ActiveEvent::SpyList << spy
      end
    end
  end
end
