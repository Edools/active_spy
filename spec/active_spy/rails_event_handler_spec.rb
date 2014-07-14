require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActiveSpy::Rails::Listener do

  class User
  end

  context 'database syncing' do

    let(:handler) { ActiveSpy::Rails::Listener.new }
    let!(:params) do
      {
        'type' => 'User',
        'action' => 'create',
        'payload' => {
          'user' => {
            'name' => 'Pedro'
          }
        },
        'actor' => {
          'type' => 'User'
        },
        'realm' => {
          'type' => 'UserRealm'
        }
      }
    end

    it 'should be able to sync a model creation' do
      params['action'] = 'create'
      expect_any_instance_of(User).to receive(:update_attributes)
        .with('name' => 'Pedro')
      expect(handler).to receive(:create).with('User',
        hash_including('name' => 'Pedro'),
        hash_including('type' => 'User'),
        hash_including('type' => 'UserRealm')
      ).and_call_original

      handler.handle(params)
    end

    it 'should be able to sync a model update' do
      params['action'] = 'update'
      params['payload']['user']['guid'] = 1

      expect_any_instance_of(User).to receive(:update_attributes)
        .with('name' => 'Pedro', 'guid' => 1)
      expect(User).to receive(:find_by).with(guid: 1).and_return(User.new)
      expect(handler).to receive(:update).with('User',
        hash_including('guid' => 1, 'name' => 'Pedro'),
        hash_including('type' => 'User'),
        hash_including('type' => 'UserRealm')
      ).and_call_original

      handler.handle(params)
    end

    it 'should be able to sync a model deletion' do
      params['action'] = 'destroy'
      params['payload']['user']['guid'] = 1

      expect(User).to receive(:find_by).with(guid: 1).and_return(User.new)
      expect_any_instance_of(User).to receive(:destroy!)
      expect(handler).to receive(:destroy).with('User',
        hash_including('guid' => 1, 'name' => 'Pedro'),
        hash_including('type' => 'User'),
        hash_including('type' => 'UserRealm')
      ).and_call_original

      handler.handle(params)
    end
  end

end
