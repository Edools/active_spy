class User < ActiveRecord::Base
  watch_method :save
end
