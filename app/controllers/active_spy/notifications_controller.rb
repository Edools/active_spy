module ActiveSpy
  class NotificationsController < ActionController::Base
    def handle
      hooks = ActiveSpy::Rails::HookList.hooks
      current_hook = nil
      hooks.each do |hook|
        if hook['post_class'].downcase == params['class']
          "#{hook['post_class']}Listener".constantize.new.handle(params['event'])
        end
      end
    end
  end
end
