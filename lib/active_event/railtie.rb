require 'rails'

module ActiveEevent
  # Railtie class to automatically include {ActiveEvent::Spy} in all
  # +ActiveRecord::Base+
  #
  class Railtie < Rails::Railtie
    initializer 'active_event.spies' do
      ActiveSupport.on_load(:active_record) do
        include ActiveEvent::Spy
      end
    end
  end
end
