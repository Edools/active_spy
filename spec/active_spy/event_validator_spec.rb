require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActiveSpy::Rails::Validation::Event do

  context 'actor validation' do
    it 'should raise exception when the actor is not present' do
      event = {}.to_json
      validator = ActiveSpy::Rails::Validation::Event.new(event)
      expect { validator.validate! }.to raise_error ActiveSpy::Rails::Validation::ActorNotPresent
    end

    it 'should raise exception when the actor is missing any attribute' do
      event = {
        'actor' => {
          # id: '1',
          'class' => 'User',
          'login' => 'user1@gmail.com',
          'url' => 'http://user.com',
          'avatar_url' => 'http://avatar_url.com'
        }
      }.to_json

      validator = ActiveSpy::Rails::Validation::Event.new(event)
      expect { validator.validate! }.to raise_error ActiveSpy::Rails::Validation::InvalidActor
    end
  end

  context 'realm validation' do
    it 'should raise exception when the realm is not present' do
      event = {
        'actor' => {
          'id' => '1',
          'class' => 'User',
          'login' => 'user1@gmail.com',
          'url' => 'http://user.com',
          'avatar_url' => 'http://avatar_url.com'
        }
      }.to_json

      validator = ActiveSpy::Rails::Validation::Event.new(event)
      expect { validator.validate! }.to raise_error ActiveSpy::Rails::Validation::RealmNotPresent
    end
  end

  it 'should raise exception when the realm is missing any attribute' do
    event = {
        'actor' => {
          'id' => '1',
          'class' => 'User',
          'login' => 'user1@gmail.com',
          'url' => 'http://user.com',
          'avatar_url' => 'http://avatar_url.com'
        },
        'realm' => {
          # 'id' => '1',
          'class' => 'Organization',
          'name' => 'my organization',
          'url' => 'http://organization.com',
        }
      }.to_json

      validator = ActiveSpy::Rails::Validation::Event.new(event)
      expect { validator.validate! }.to raise_error ActiveSpy::Rails::Validation::InvalidRealm
  end

end
