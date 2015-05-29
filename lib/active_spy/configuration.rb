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

      # Set the default event-tunner verify_ssl mode
      #
      # @param [String] host to set
      #
      # @return [String] the host set
      def event_verify_ssl(event_verify_ssl = nil)
        @event_verify_ssl = event_verify_ssl unless event_verify_ssl.nil?
        @event_verify_ssl
      end

      # Set if the gem is in development mode or not.
      #
      # @param [Boolean] development moded state to set
      #
      # @return [Boolean] development moded state to set
      def development_mode(mode = nil, options = nil)
        unless mode.nil?
          @development_mode = mode
          @skip_validations = options[:skip_validations] if options.present?
        end
        @development_mode
      end

      # Simple reader for +skip_validations+ attribute.
      #
      def skip_validations
        @skip_validations
      end

      # Imperative method to set development mode.
      #
      def development_mode!
        @development_mode = true
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
        { host: @event_host, port: @event_port, verify_ssl: @event_verify_ssl }
      end
    end
  end
end
