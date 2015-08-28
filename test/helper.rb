require 'bundler/setup'
Bundler.setup

require 'pry-byebug'
require 'minitest/autorun'
# require 'minitest/pride'
require 'active_record'
# require 'rails'
require 'dotenv'
Dotenv.load

FIXTURES_ROOT = File.expand_path(File.dirname(__FILE__)) + "/fixtures"

class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures

  self.fixture_path = FIXTURES_ROOT
  self.use_instantiated_fixtures  = false
  self.use_transactional_fixtures = true
end

ActiveRecord::Base.configurations = { "test" => { adapter: 'sqlite3', database: ':memory:' } }
ActiveRecord::Base.establish_connection(:test)

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :posts do |t|
    t.string   :title
    t.datetime :written_on
    t.time     :bonus_time
    t.date     :last_read
    t.text     :content
    t.boolean  :approved,       default: true
    t.integer  :replies_count,  default: 0
    t.integer  :author_id
    t.timestamps null: false
  end

  create_table :authors do |t|
    t.string :name
    t.string :email
  end
end

class Post < ActiveRecord::Base
  belongs_to :author
end

class Author < ActiveRecord::Base
  has_many :posts
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'active_spy'

ActiveSpy.options[:app_env] = 'test'
