require 'rails'

module ActiveEvent
  # Railtie class to automatically include {ActiveEvent::Spy} in all
  # +ActiveRecord::Base+
  #
  class Railtie < Rails::Railtie
    initializer 'active_event.spies' do
      ActiveSupport.on_load(:active_record) do
        include ActiveEvent::Spy
      end
    end

    config.after_initialize do
      Rails.application.eager_load!
      ActiveEvent::SpyList.activate
    end
  end
end
