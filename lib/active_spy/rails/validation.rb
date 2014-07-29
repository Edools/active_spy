require 'json'

module ActiveSpy
  module Rails
    # Module to hold classes that are intended to validate something.
    #
    module Validation
      # Class responsible to validate event that are send to event-runner
      # instances.
      #
      class Event

        def initialize(event_json)
          @event = JSON.load(event_json)
        end

        def validate!
          check_actor_key(@event['actor'])
          check_realm_key(@event['realm'])
        end

        private
        def check_actor_key(actor)
          raise ActorNotPresent if actor.nil?
          errors = get_errors_from_hash(actor, :actor)
          raise InvalidActor, errors unless errors.empty?
        end

        def check_realm_key(realm)
          raise RealmNotPresent if realm.nil?
          errors = get_errors_from_hash(realm, :realm)
          raise InvalidRealm, errors unless errors.empty?
        end

        def get_errors_from_hash(data, hash_type)
          keys = hash_type == :actor ? required_actor_keys : required_realm_keys
          keys.map do |key|
            "#{key} should not be empty." if data[key].nil?
          end.compact.join(' ')
        end

        def required_actor_keys
          ['id', 'class', 'login', 'url', 'avatar_url']
        end

        def required_realm_keys
          ['id', 'class', 'name', 'url']
        end
      end

      class ActorNotPresent < RuntimeError
      end

      class InvalidActor < RuntimeError
      end

      class RealmNotPresent < RuntimeError
      end

      class InvalidRealm < RuntimeError
      end
    end
  end
end
