module ActiveEvent
  module Rails
    # Base class used to process the events received.
    #
    class EventHandler
      include ActiveSupport::Inflector

      # Constant to hold the model translations. The key is the incoming
      # +ref_type+ and the value is the matching model class.
      #
      MODEL_HANDLER = {}

      # Handle a request with +params+ and sync the database according to
      # them.
      #
      def handle(params)
        object_type, callback = params.delete(:type), params[:payload].delete(:action)
        payload_content = params.delete(:payload)[object_type.downcase.to_sym]
        sync_database(callback, object_type, payload_content)
      end

      # Calls the proper method to sync the database. It will manipulate
      # objects of the class +object_type+, with the attributes sent in the
      # +payload+, triggered by the callback +callback+.
      #
      def sync_database(callback, object_type, payload)
        send(callback, callback, object_type, payload)
      end

      # Logic to handle object's creation and updates.
      #
      def save(callback, object_type, payload)
        klass = get_object_class(callback, object_type)
        object = get_object(payload, klass)
        object.update_attributes(payload)
      end

      # Gets the object according to the operation sent by the server.
      #
      def get_object(payload, klass)
        if new_record?(payload)
          klass.new
        else
          id = payload.delete(:id)
          klass.find(id)
        end
      end

      # Check if a record sent in the payload if a new record. If it has an id,
      # it is not a new one.
      #
      def new_record?(payload)
        payload[:id].nil?
      end

      # Destroy a record from our database.
      #
      def destroy(callback, klass, payload)
        klass = get_object_class(callback, klass)
        id = payload.delete(:id)
        klass.find(id).destroy!
      end

      # Gets the object class. First, it'll look the {MODEL_HANDLER} hash and
      # see if there is any translation for a given +object_type+. If it does
      # not have a translation, this method will try to +constantize+ the
      # +object_type+.
      #
      def get_object_class(callback, object_type)
        translated_object_type = MODEL_HANDLER[object_type]
        return constantize(translated_object_type) if translated_object_type
        constantize(object_type)
      end
    end
  end
end
