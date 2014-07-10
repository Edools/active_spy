require 'active_support'
require 'singleton'

module ActiveSpy
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

    attr_reader :spies

    # Proxy all methods called in the {ActiveSpy::SpyList} to
    # {ActiveSpy::SpyList} instance. Just a syntax sugar.
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

    # This method patches the +method+ in the class +klass+ to invoke the
    # callbacks defined in the respective class, that should be named using
    # appending 'Events' to the class' name, and inherites from
    # {ActiveSpy::Base}.
    #
    def patch(klass, method)
      ActiveSupport::Inflector.constantize(klass).class_eval do

        old_method = instance_method(method)
        define_method method do
          send(:invoke_callback, method, :before)
          result = old_method.bind(self).call
          send(:invoke_callback, method, :after)
          result
        end
      end
    end
  end
end
