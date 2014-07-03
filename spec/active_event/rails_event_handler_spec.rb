require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActiveEvent::Rails::EventHandler do

  class User
  end

  context 'database syncing' do

    let(:handler) { ActiveEvent::Rails::EventHandler.new }
    let!(:params) do
      {
        type: 'User',
        payload: {
          user: {
            name: 'Pedro'
          },
          action: 'save'
        }
      }
    end

    it 'should be able to sync a model creation' do
      expect_any_instance_of(User).to receive(:update_attributes).with(name: 'Pedro')
      expect(handler).to receive(:save).with('save', 'User', name: 'Pedro').and_call_original

      handler.handle(params)
    end

    it 'should be able to sync a model update' do
      params[:payload][:user][:id] = 1

      expect_any_instance_of(User).to receive(:update_attributes).with(name: 'Pedro')
      expect(User).to receive(:find).with(1).and_return(User.new)
      expect(handler).to receive(:save).with('save', 'User', id: 1, name: 'Pedro').and_call_original

      handler.handle(params)
    end

    it 'should be able to sync a model deletion' do
      params[:payload][:action] = 'destroy'
      params[:payload][:user][:id] = 1

      expect(User).to receive(:find).with(1).and_return(User.new)
      expect_any_instance_of(User).to receive(:destroy!)
      expect(handler).to receive(:destroy).with('destroy', 'User', id: 1, name: 'Pedro').and_call_original

      handler.handle(params)
    end
  end

end
