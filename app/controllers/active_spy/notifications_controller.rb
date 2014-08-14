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
          listener = "#{hook['post_class']}Listener".constantize
          result = listener.new.handle(params['event'])
          if result.errors.present?
            Rails.logger.warn("[EVENT][#{hook['post_class']}] Error on save #{result}: #{result.errors}")
            render json: result.errors
          else
            render json: result
          end and return
        end
      end
      render nothing: true, status: :not_found
    end
  end
end
