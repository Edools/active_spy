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

        # Validates the +event_json+ provided in the initializer
        #
        # (see #initialize)
        def validate!
          check_actor_key(@event['actor'])
          check_realm_key(@event['realm'])
        end

        private

        # Check if actor is valid.
        #
        def check_actor_key(actor)
          fail ActorNotPresent if actor.nil?
          errors = get_errors_from_hash(actor, :actor)
          fail InvalidActor, errors unless errors.empty?
        end

        # Check if realm is valid.
        #
        def check_realm_key(realm)
          fail RealmNotPresent if realm.nil?
          errors = get_errors_from_hash(realm, :realm)
          fail InvalidRealm, errors unless errors.empty?
        end

        # Get the error from +data+ regarding +hash_type+ checking if the
        # required keys are being provided.
        #
        def get_errors_from_hash(data, hash_type)
          keys = hash_type == :actor ? required_actor_keys : required_realm_keys
          keys.map do |key|
            "#{key} should not be empty." if data[key].nil?
          end.compact.join(' ')
        end

        # Required keys for an actor to be valid.
        #
        def required_actor_keys
          %w[id class login url avatar_url]
        end

        # Required keys for realm to be valid.
        #
        def required_realm_keys
          %w[id class name url]
        end
      end

      # Error when actor is not present.
      #
      class ActorNotPresent < RuntimeError
      end

      # Error when the actor is invalid.
      #
      class InvalidActor < RuntimeError
      end

      # Error when realm is not present.
      #
      class RealmNotPresent < RuntimeError
      end

      # Error when the realm is invalid.
      #
      class InvalidRealm < RuntimeError
      end
    end
  end
end
