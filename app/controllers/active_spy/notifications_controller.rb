module ActiveSpy
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
            render json: result.errors
          else
            render json: result
          end
          return
        end
      end
      render nothing: true, status: :not_found
    end
  end
end
