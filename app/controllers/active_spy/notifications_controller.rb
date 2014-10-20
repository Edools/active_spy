class UnsupportedORM < RuntimeError
end

module ActiveSpy
  # Controller to handle notifications request coming from an event-runner
  # instance.
  #
  class NotificationsController < ActionController::Base
    def handle
      request.format = 'application/json'
      hooks = ActiveSpy::Rails::HookList.hooks
      result = nil
      hooks.each do |hook|
        if hook['post_class'].downcase == params['class']
           handle_result(hook, params) and return
        end
      end
      render nothing: true, status: :not_found
    end

    def handle_result(hook, params)
      result = get_result(hook, params)
      ::Rails.logger.warn("[EVENT][#{hook['post_class']}] Listener result: #{result}")
      if result.is_a? Array
        handle_array_result(hook, result, params)
      elsif is_a_model?(result)
        handle_model_result(hook, result, params)
      else
        render nothing: true
      end
    end

    def is_a_model?(something)
      if defined?(ActiveRecord)
        something.is_a? ActiveRecord::Base
      elsif defined?(Mongoid)
        something.class.included_modules.include? Mongoid::Document
      else
        raise UnsupportedORM
      end
    end

    def get_result(hook, params)
      listener = "#{hook['post_class']}Listener".constantize
      result = listener.new.handle(params['event'])
    end

    def handle_model_result(hook, result, params)
      if result.errors.present?
        ::Rails.logger.warn("[EVENT][#{hook['post_class']}] Error receiving event #{params}")
        ::Rails.logger.warn("[EVENT][#{hook['post_class']}] Result errors: #{result.errors.full_messages}")
        render json: result.errors, status: :unprocessable_entity
      else
        render nothing: true
      end
    end

    def handle_array_result(hook, result, params)
      model_with_errors = result.select { |m| m.errors.present? }
      if model_with_errors.any?
        ::Rails.logger.warn("[EVENT][#{hook['post_class']}] Error receiving event #{params}")
        model_with_errors.each do |model|
          ::Rails.logger.warn("[EVENT][#{hook['post_class']}] #{model} errors: #{model.errors.full_messages}")
        end
        render nothing: true, status: :internal_server_error
      else
        render nothing: true
      end
    end
  end
end
