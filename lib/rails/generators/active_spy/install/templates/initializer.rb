Rails.application.eager_load!
ActiveSpy::SpyList.activate

if Rails.env.production?
  ActiveSpy.register_service
  ActiveSpy::Rails::HookList.register
end
