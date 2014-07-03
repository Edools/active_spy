class Product < ActiveRecord::Base

  watch_method :save

  def payload_for(method)
    {product: attributes}
  end

  def realm
    'my realm'
  end

end
