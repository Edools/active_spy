module ActiveSpy
  # Defines a class to hold the configuration used to send events.
  #
  class Configuration
    class << self
      # Set the application host
      #
      # @param [String] host to set
      #
      # @return [String] the host set
      def host(host = nil)
        @host = host unless host.nil?
        @host
      end

      # Set the application port
      #
      # @param [String] port to set
      #
      # @return [String] the port set
      def port(port = nil)
        @port = port unless port.nil?
        @port
      end

      # Set the application name
      #
      # @param [String] name to set
      #
      # @return [String] the name set
      def name(name = nil)
        @name = name unless name.nil?
        @name
      end

      # Set the default event-runner host
      #
      # @param [String] host to set
      #
      # @return [String] the host set
      def event_host(host = nil)
        @event_host = host unless host.nil?
        @event_host
      end

      # Set the default event-runner port
      #
      # @param [String] port to set
      #
      # @return [String] the port set
      def event_port(port = nil)
        @event_port = port unless port.nil?
        @event_port
      end

      # See how are the settings
      #
      # @return [Hash] actual settings
      def settings
        { name: @name, hostname: @host, port: @port }
      end

      # See how are the event settings
      #
      # @return [Hash] actual event settings
      def event_settings
        { host: @event_host, port: @event_port }
      end
    end
  end
end
