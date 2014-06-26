module ActiveEvent
  # Make requests to the event-runner service using the object whose method
  # was being watched.
  #
  class Base
    def initialize(object)
      @object = object
    end
  end
end
