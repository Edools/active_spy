class UserEvents < ActiveEvent::Base

  def before_save
    @object.name += ' event'
  end

end
