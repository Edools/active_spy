class Product < ActiveRecord::Base

  watch_model_changes
  model_realm :my_realm
  model_actor :actor

end
