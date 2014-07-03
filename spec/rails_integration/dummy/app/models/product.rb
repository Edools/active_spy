class Product < ActiveRecord::Base

  watch_model_changes

  def payload_for(method)
    {product: attributes}
  end

  def realm
    'my realm'
  end

end
