module ActiveEvent
  # Class responsible for the controller and routes integration with Rails
  #
  class Engine < ::Rails::Engine
    isolate_namespace ActiveEvent
  end
end
