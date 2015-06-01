module ActiveSpy
  module Rails
    # Class used to hold all the events hook's paths and later sync
    # them with an event runner instance.
    #
    class HookList
      include Singleton

      # Simple attribute reader for hooks
      #
      attr_reader :hooks

      # Initialize an empty hook list
      #
      def initialize
        host = ActiveSpy::Configuration.event_host
        port = ActiveSpy::Configuration.event_port
        name = ActiveSpy::Configuration.name.downcase.gsub(' ', '-').strip

        @verify_ssl       = ActiveSpy::Configuration.event_verify_ssl
        @base_service_url = "#{host}:#{port}/services/#{name}"
        @hooks            = []
      end

      # Proxy all methods called in the {ActiveSpy::Hook} to
      # {ActiveSpy::Hook} instance. Just a syntax sugar.
      #
      def self.method_missing(method, *args, &block)
        instance.send(method, *args, &block)
      end

      # Clear the hook list.
      #
      def clear
        @hooks = []
      end

      # forward {<<} method to the hook list.
      #
      def <<(other)
        @hooks << other
      end

      # Register in event runner all the hooks defined in the list. If some of
      # them already exists, they will be excluded and readded.
      #
      def register
        @hooks = @hooks.map(&:to_hook).flatten
        old_hooks = get_old_hooks
        hooks_to_delete = get_hooks_to_delete(old_hooks)
        hooks_to_add = get_hooks_to_add(old_hooks)
        delete_hooks(hooks_to_delete) if hooks_to_delete.any?
        add_hooks(hooks_to_add) unless hooks_to_add.empty?
      end

      # Get the old hooks list for this service from the event-runner
      #
      def get_old_hooks
        request = if @verify_ssl
          RestClient::Request.execute(method: :get, url: @base_service_url, verify_ssl: @verify_ssl)
        else
          RestClient.get(@base_service_url)
        end

        JSON.load(request)['hooks']
      end

      # Select from old hooks those that should be deleted from event runner.
      #
      def get_hooks_to_delete(old_hooks)
        hooks_to_delete = []
        old_hooks.each do |old_hook|
          found = false
          @hooks.each do |hook|
            if hook['class'] == old_hook['class'] && old_hook['active']
              found = true
              break
            end
          end
          next if found
          hooks_to_delete << old_hook
        end
        hooks_to_delete
      end

      # Select from the hooks defined in the app those that should be created
      # in the event runner.
      #
      def get_hooks_to_add(old_hooks)
        hooks_to_add = []
        @hooks.each do |hook|
          found = false
          old_hooks.each do |old_hook|
            if hook['class'] == old_hook['class'] && old_hook['active']
              found = true
              break
            end
          end
          next if found
          hooks_to_add << hook
        end
        hooks_to_add
      end

      # Properly delete the +hooks_to_delete+ in the event runner.
      #
      def delete_hooks(hooks_to_delete)
        hooks_to_delete.each do |hook|
          url = "#{@base_service_url}/hooks/#{hook['id']}"
          if @verify_ssl
            RestClient::Request.execute(method: :delete, url: url, verify_ssl: @verify_ssl)
          else
            RestClient.delete url
          end
        end
      end

      # # Properly creates the +hooks_to_add+ in the event runner.
      #
      def add_hooks(hooks_to_add)
        url = "#{@base_service_url}/hooks"

        hooks_to_add.each do |hook|
          hook = {
            'hook' => {
              'class' => hook['class'],
              'post_path' => ActiveSpy::Engine.routes.url_helpers.notifications_path(hook['post_class'].downcase),
            }
          }

          if @verify_ssl
            RestClient::Request.execute(content_type: :json, method: :post,
              url: url, payload: hook.to_json, verify_ssl: @verify_ssl)
          else
            RestClient.post url, hook.to_json, content_type: :json
          end
        end
      end
    end
  end
end
