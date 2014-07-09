ActiveEvent::SpyList.activate

if Rails.env.production?
  ActiveEvent.register_service
  ActiveEvent::Rails::HookList.register
end

