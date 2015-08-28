require 'shoryuken'
require 'active_support'

require 'active_spy/station'
require 'active_spy/agent'
require 'active_spy/handler'

module ActiveSpy
  DEFAULTS = {
    app_name: 'ActiveSpy',
    app_env: 'development',
    fake_clients: false,
    aws: {}
  }

  class << self
    def options
      @options ||= DEFAULTS.dup
    end
  end
end
