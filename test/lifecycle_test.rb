require 'helper'
require 'shoryuken'

config_file = File.join(File.expand_path('../', __FILE__), 'support', 'shoryuken.yml')
Shoryuken::EnvironmentLoader.load(config_file: config_file)

class Post < ActiveRecord::Base
  include ActiveSpy::Agent
end

class ActiveSpyPostHandler
  include ActiveSpy::Handler

  @@received_messages = {}

  def self.received_messages
    @@received_messages
  end

  def self.received_messages=(received_messages)
    @@received_messages = received_messages
  end

  def create(type, payload, actor)
    @@received_messages[:create] = {
      'action'  =>   'create',
      'type'    =>     type,
      'payload' =>  payload,
      'actor'   =>    actor
    }
  end

  def update(type, payload, actor)
    @@received_messages[:update] = {
      'action'  =>   'update',
      'type'    =>     type,
      'payload' =>  payload,
      'actor'   =>    actor
    }
  end

  def destroy(type, payload, actor)
    @@received_messages[:destroy] = {
      'action'  =>   'destroy',
      'type'    =>     type,
      'payload' =>  payload,
      'actor'   =>    actor
    }
  end
end

class LifeCycleTest < ActiveSupport::TestCase
  fixtures :authors, :posts

  def setup
    @sqs_client = ActiveSpyPostHandler.send(:sqs_client)
    @sqs_queue_name = ActiveSpyPostHandler.send(:sqs_queue_name)

    Shoryuken.options[:aws][:receive_message] = { wait_time_seconds: 5 }

    ActiveSpyPostHandler.received_messages = {}

    Shoryuken.queues << @sqs_queue_name

    Shoryuken.register_worker @sqs_queue_name, ActiveSpyPostHandler
  end

  def teardown
    # ActiveSpyPostHandler.delete_sqs_queue
  end

  test "broadcast create update and destroy events" do
    post_attrs = posts(:first).attributes
    post_attrs.delete('id')
    james = authors(:james)
    bond = authors(:bond)

    post = Post.create!(post_attrs)

    ActiveSpy::Agent.current_actor = james

    post.update!(title: 'My First Post v2')

    ActiveSpy::Agent.current_actor = bond

    post.destroy!

    poll_queues_until { ActiveSpyPostHandler.received_messages.count == 3 }
    create_message = ActiveSpyPostHandler.received_messages[:create]
    update_message = ActiveSpyPostHandler.received_messages[:update]
    destroy_message = ActiveSpyPostHandler.received_messages[:destroy]

    assert_equal('create', create_message['action'])
    assert_equal('post', create_message['type'])
    assert_equal(nil, create_message['actor'])
    assert_payload(post_attrs.merge({id: post.id}), create_message['payload'])

    assert_equal('update', update_message['action'])
    assert_equal('post', update_message['type'])
    assert_equal(james.attributes, update_message['actor'])
    assert_payload(post.attributes, update_message['payload'])

    assert_equal('destroy', destroy_message['action'])
    assert_equal('post', destroy_message['type'])
    assert_equal(bond.attributes, destroy_message['actor'])
    assert_payload(post.attributes, destroy_message['payload'])
  end

  private

  def assert_payload(expected, actual)
    expected  = expected.as_json
    actual    = actual.as_json

    assert_equal expected.keys.count, actual.keys.count

    expected.each do |key, value|
      assert_equal value, actual[key]
    end
  end

  def poll_queues_until
    queue = Shoryuken::Client.queues(@sqs_queue_name)

    Timeout::timeout(10) do
      begin
        if (sqs_msgs = Array(receive_messages(queue))).any?
          sqs_msgs.each { |sqs_msg| process(sqs_msg) }
        end
        sleep 0.5
      end until yield
    end
  end

  def receive_messages(queue)
    options = (Shoryuken.options[:aws][:receive_message] || {}).dup
    options[:max_number_of_messages] = 10
    options[:message_attribute_names] = %w(All)
    options[:attribute_names] = %w(All)

    queue.receive_messages(options)
  end

  def process(sqs_msg)
    worker = ActiveSpyPostHandler.new

    body = JSON.parse(sqs_msg.body)

    worker.class.server_middleware.invoke(worker, @sqs_queue_name, sqs_msg, body) do
      worker.perform(sqs_msg, body)
    end
  end
end
