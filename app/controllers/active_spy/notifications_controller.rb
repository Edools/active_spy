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
  end

  def handle_result(hook, params)
    result = get_result(hook, params)
    if result.is_a? Array
      handle_array_result(result, params)
    else
      handle_model_result(result, params)
    end
  end


  def get_result(hook, params)
    listener = "#{hook['post_class']}Listener".constantize
    result = listener.new.handle(params['event'])
  end

  def handle_model_result(result, params)
    if result.errors.present?
      Rails.logger.warn("[EVENT][#{hook['post_class']}] Error receiving event #{params}")
      Rails.logger.warn("[EVENT][#{hook['post_class']}] Listener result: #{result}")
      Rails.logger.warn("[EVENT][#{hook['post_class']}] Result errors: #{result.errors}")
      render json: result.errors
    else
      render nothing: true
    end
  end

  def handle_array_result(result, params)
    model_with_errors = result.select { |m| m.errors.present? }
    if model_with_errors.any?
      Rails.logger.warn("[EVENT][#{hook['post_class']}] Error receiving event #{params}")
      Rails.logger.warn("[EVENT][#{hook['post_class']}] Listener result: #{result}")
      model_with_errors.each do |model|
        Rails.logger.warn("[EVENT][#{hook['post_class']}] #{model} errors: #{model.errors}")
      end
    else
      render nothing: true
    end
  end
end
