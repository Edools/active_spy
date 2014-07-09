module ActiveEvent
  # Default template for callbacks handlers.
  #
  class Base
    def initialize(object)
      @object = object
    end
  end
end
