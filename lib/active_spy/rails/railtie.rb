require 'rails'

# Railtie class to automatically include {ActiveSpy::Spy} in all
# +ActiveRecord::Base+
#
class Railtie < Rails::Railtie
  initializer 'active_spy.spies' do
    ActiveSupport.on_load(:active_record) do
      include ActiveSpy::Spy
      include ActiveSpy::Rails::Spy
    end
  end
end
