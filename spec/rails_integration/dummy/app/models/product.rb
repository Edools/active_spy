class Product < ActiveRecord::Base

  watch_method :save


  def payload_for(method)
    to_json
  end

  def realm
    'my realm'
  end

end
