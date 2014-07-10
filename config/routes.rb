ActiveSpy::Engine.routes.draw do
  post '/notifications/:class' => 'notifications#handle', as: :notifications
end
