module ActiveEvent
  # Defines a class to hold the configuration used to send events.
  #
  class Configuration
    class << self
      # Set the default event-runner host
      #
      #
      # @param [String] host to set
      #
      # @return [String] the host set
      def host(host = nil)
        @host = host unless host.nil?
        @host
      end

      # Set the default event-runner port
      #
      #
      # @param [String] port to set
      #
      # @return [String] the port set
      def port(port = nil)
        @port = port unless port.nil?
        @port
      end

      # See how are the settings
      #
      # @return [Hash] actual settings
      def settings
        { host: @host, port: @port }
      end
    end
  end
end
