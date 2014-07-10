class UserEvents < ActiveSpy::Base

  def before_save
    @object.name += ' event'
  end

end
