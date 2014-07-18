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

    # Activate all the spies defined in the spy list by patching the methods
    # in their classes.
    #
    def activate
      @spies.each do |spy|
        spied_class = spy['class']
        spied_method = spy['method']

        spy['old_method'] = patch(spied_class, spied_method) unless spy['active']
        spy['active'] = true
      end
    end

    # Deactivate all the spies defined in the spy list by unpatching the methods
    # in their classes.
    #
    def deactivate
      @spies.each do |spy|
        unpatch(spy['class'], spy['method'], spy['old_method'])
        spy['active'] = nil
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
      old_method = nil
      ActiveSupport::Inflector.constantize(klass).class_eval do

        old_method = instance_method(method)
        define_method method do |*args, &block|
          send(:invoke_callback, method, :before)
          result = old_method.bind(self).call(*args, &block)
          send(:invoke_callback, method, :after)
          result
        end
      end
      old_method
    end

    # Properyly unpatch the +method+ in class +klass+ and put back +old_method+
    # in its place.
    #
    def unpatch(klass, method, old_method)
      ActiveSupport::Inflector.constantize(klass).class_eval do
        define_method method do |*args, &block|
          old_method.bind(self).call(*args, &block)
        end
      end
    end
  end
end
