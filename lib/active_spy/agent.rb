module ActiveSpy
  module Agent
    extend ActiveSupport::Concern
    include Station

    included do
      after_create :broadcast_create
      after_update :broadcast_update
      after_destroy :broadcast_destroy
    end

    def broadcast_create
      broadcast_event('create')
    end

    def broadcast_update
      broadcast_event('update')
    end

    def broadcast_destroy
      broadcast_event('destroy')
    end

    def broadcast_event(action)
      # Rails.logger.debug("[SPY] - Broadcasting event #{self.class.name.underscore}##{action}")
      params = event_params(action)
      # Rails.logger.debug("[SPY] - Event #{self.class.name.underscore}##{action} params: #{params.inspect}")
      self.class.report!(params)
      # Rails.logger.debug("[SPY] - Event #{self.class.name.underscore}##{action} sent!")
    end

    def event_params(action)
      {
        type:     self.class.name.underscore,
        actor:    payload_for_actor,
        payload:  payload_for(action),
        action:   action
      }
    end

    def payload_for(action)
      attributes
    end

    def payload_for_actor
      actor = ActiveSpy::Agent.current_actor

      if actor
        actor.respond_to?(:to_actor) ? actor.to_actor : actor.attributes
      end
    end

    def self.current_actor
      RequestStore.store[:current_actor]
    end

    def self.current_actor=(actor)
      RequestStore.store[:current_actor] = actor
    end

    module ClassMethods
      def report!(event)
        # Rails.logger.debug("[SPY] - Publishing event to SNS Topic #{sns_topic.topic_arn}")
        sns_client.publish({
          topic_arn: sns_topic.topic_arn,
          message: event.to_json
        })
      end

      private

      def delete_sns_topic
        sns_client.delete_topic(topic_arn: sns_topic.topic_arn)
      end
    end
  end
end
