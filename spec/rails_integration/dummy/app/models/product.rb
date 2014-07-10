class Product < ActiveRecord::Base

  watch_model_changes
  model_realm { 'my realm' }
  model_actor :actor

  def actor
    'my actor'
  end

end
