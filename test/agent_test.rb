require 'helper'

class Post < ActiveRecord::Base
  include ActiveSpy::Agent
end

class AgentTest < ActiveSupport::TestCase
  fixtures :authors, :posts

  def setup
  end

  def teardown
  end
end
