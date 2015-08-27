require 'helper'
require 'shoryuken'
require 'shoryuken/manager'
require 'shoryuken/launcher'

config_file = File.join(File.expand_path('../', __FILE__), 'support', 'shoryuken.yml')
Shoryuken::EnvironmentLoader.load(config_file: config_file)

class Post < ActiveRecord::Base
  include ActiveSpy::Agent
end

class PostHandler
  include ActiveSpy::Handler

  @@received_messages = []

  def self.received_messages
    @@received_messages
  end

  def self.received_messages=(received_messages)
    @@received_messages = received_messages
  end

  def create(type, payload, actor)
    @@received_messages << {
      action:   'create',
      type:     type,
      payload:  payload,
      actor:    actor
    }
  end

  def update(type, payload, actor)
    @@received_messages << {
      action:   'update',
      type:     type,
      payload:  payload,
      actor:    actor
    }
  end

  def destroy(type, payload, actor)
    @@received_messages << {
      action:   'destroy',
      type:     type,
      payload:  payload,
      actor:    actor
    }
  end
end

class LifeCycleTest < ActiveSupport::TestCase
  fixtures :authors, :posts

  def setup
    Shoryuken.options[:aws][:receive_message] = { wait_time_seconds: 5 }

    PostHandler.received_messages = []

    Shoryuken.queues << PostHandler.send(:sqs_queue)

    Shoryuken.register_worker PostHandler.send(:sqs_queue_name), PostHandler
  end

  def teardown
    # PostHandler.delete_sqs_queue
  end

  test "broadcast create, update and destroy events" do
    post_attrs = posts(:first).attributes
    post_attrs.delete('id')

    post = Post.create!(post_attrs)
    post.update!(title: 'My First Post v2')
    post.destroy!

    poll_queues_until { PostHandler.received_messages.count == 3 }

    create_message = PostHandler.received_messages.shift
    update_message = PostHandler.received_messages.shift
    destroy_message = PostHandler.received_messages.shift

    assert_equal('create', create_message[:actrion])
    assert_equal('post', create_message[:type])
    assert_equal({}, create_message[:payload])
    assert_equal({}, create_message[:actor])

    assert_equal('update', update_message[:actrion])
    assert_equal('post', update_message[:type])
    assert_equal({}, update_message[:payload])
    assert_equal({}, update_message[:actor])

    assert_equal('destroy', destroy_message[:actrion])
    assert_equal('post', destroy_message[:type])
    assert_equal({}, destroy_message[:payload])
    assert_equal({}, destroy_message[:actor])
  end

  private

  def poll_queues_until
    Shoryuken::Launcher.run

    Timeout::timeout(10) do
      begin
        sleep 0.5
      end until yield
    end
  ensure
    Shoryuken::Launcher.stop
  end
end
