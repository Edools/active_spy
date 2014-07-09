module ActiveEvent
  module Rails
    # Class used to hold all the events hook's paths and later sync
    # them with an event runner instance.
    #
    class HookList
      include Singleton

      # Initialize an empty hook list
      #
      def initialize
        @hooks = []
      end

      # Proxy all methods called in the {ActiveEvent::Hook} to
      # {ActiveEvent::Hook} instance. Just a syntax sugar.
      #
      def self.method_missing(method, *args, &block)
        instance.send(method, *args, &block)
      end

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
        old_hooks = get_old_hooks
        hooks_to_delete = get_hooks_to_delete(old_hooks)
        hooks_to_add = get_hooks_to_add(old_hooks)
        delete_hooks(hooks_to_delete) if hooks_to_delete.any?
        add_hooks(hooks_to_add) unless hooks_to_add.empty?
      end

      def get_old_hooks
        host = ActiveEvent::Configuration.event_host
        port = ActiveEvent::Configuration.event_port
        name = ActiveEvent::Configuration.name.downcase.gsub(' ', '-').strip
        JSON.load(RestClient.get("#{host}:#{port}/services/#{name}"))['hooks']
      end

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

      def delete_hooks(hooks_to_delete)
        host = ActiveEvent::Configuration.event_host
        port = ActiveEvent::Configuration.event_port
        name = ActiveEvent::Configuration.name.downcase.gsub(' ', '-').strip
        hooks_to_delete.each do |hook|
          RestClient.delete "#{host}:#{port}/services/#{name}/hooks/#{hook['id']}"
        end
      end

      def add_hooks(hooks_to_add)
        host = ActiveEvent::Configuration.event_host
        port = ActiveEvent::Configuration.event_port
        name = ActiveEvent::Configuration.name.downcase.gsub(' ', '-').strip
        hooks_to_add.each do |hook|
          RestClient.post "#{host}:#{port}/services/#{name}/hooks", {
            'class'=> hook['class'],
            'postPath' => ActiveEvent::Engine.routes.url_helpers.notifications_path(hook['class'].downcase),
            'active' => true
          }
        end
      end
    end
  end
end
