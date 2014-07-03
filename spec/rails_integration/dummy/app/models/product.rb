class Product < ActiveRecord::Base

  watch_model_changes
  model_realm { 'my realm' }

end
