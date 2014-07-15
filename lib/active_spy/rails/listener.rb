require 'rest-client'
require 'json'

module ActiveSpy
  module Rails
    # Base class used to process the events received.
    #
    class Listener
      include ActiveSupport::Inflector


      # Constant to hold the model translations. The key is the incoming
      # +ref_type+ and the value is the matching model class.
      #
      MODEL_HANDLER = {}

      # Store the event handler hook in the {ActiveSpy::Rails::HookList} for
      # later registration of them within the event runner.
      #
      def self.inherited(child)
        ActiveSpy::Rails::HookList << child
      end

      def self.external_class(klass)
        @@external_class = klass
      end

      def self.to_hook
        { 'class' => hook_class, 'post_class'=> name.split('Listener')[0] }
      end

      def self.hook_class
        return @@external_class if defined? @@external_class
        name.split('Listener')[0]
      end

      # Handle a request with +params+ and sync the database according to
      # them.
      #
      def handle(params)
        object_type = params.delete('type')
        callback = params.delete('action')
        payload_content = params.delete('payload')[object_type.downcase]
        actor = params.delete('actor')
        realm = params.delete('realm')
        sync_database(callback, object_type, payload_content, actor, realm)
      end

      # Calls the proper method to sync the database. It will manipulate
      # objects of the class +object_type+, with the attributes sent in the
      # +payload+, triggered by the callback +callback+.
      #
      def sync_database(callback, object_type, payload, actor, realm)
        send(callback, object_type, payload, actor, realm)
      end

      # Logic to handle object's creation. You can override this, as you wish,
      # to suit your own needs
      #
      def create(object_type, payload, _actor, _realm)
        klass = get_object_class(object_type)
        object = klass.new
        object.update_attributes(payload)
        object
      end

      # Logic to handle object's update. You can override this, as you wish,
      # to suit your own needs
      #
      def update(object_type, payload, _actor, _realm)
        klass = get_object_class(object_type)
        guid = payload['guid']
        object = klass.find_by(guid: guid)
        object.update_attributes(payload)
        object
      end

      # Destroy a record from our database. You can override this, as you wish,
      # to suit your own needs
      #
      def destroy(klass, payload, _actor, _realm)
        klass = get_object_class(klass)
        guid = payload.delete('guid')
        object = klass.find_by(guid: guid)
        object.destroy!
        object
      end

      # Gets the object class. First, it'll look the {MODEL_HANDLER} hash and
      # see if there is any translation for a given +object_type+. If it does
      # not have a translation, this method will try to +constantize+ the
      # +object_type+.
      #
      def get_object_class(object_type)
        translated_object_type = MODEL_HANDLER[object_type]
        return constantize(translated_object_type) if translated_object_type
        constantize(object_type)
      end
    end
  end
end
