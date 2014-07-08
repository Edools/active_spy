# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!
load "#{Rails.root.to_s}/db/schema.rb"
