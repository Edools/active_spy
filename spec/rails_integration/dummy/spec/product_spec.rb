require 'spec_helper'

describe Product do

  it 'should send itself to a event-runner instance' do
    right_now = Time.now
    product = Product.new name: 'Foo', id: 1, guid: '123', created_at: right_now,
      updated_at: right_now
    product.actor = 'my actor'
    product.my_realm = 'my realm'


    expect(RestClient).to receive(:post).with('http://event-runner.com:443/',
      hash_including(
        event: {
          payload: {
            product: product.attributes,
          },
          action: 'create',
          realm: 'my realm',
          actor: 'my actor',
          type: 'Product'
        }
      )
    )

    product.save
    expect(product.my_realm).to eql('my realm')
  end

  context 'service registration' do
    it 'should register service when register_service is called' do
      response = double('response')
      expect(response).to receive(:code).and_return(404)

      expect(RestClient).to receive(:get).
        with('http://event-runner.com:443/services/dummy').and_return(response)

      expect(RestClient).to receive(:post).with('http://event-runner.com:443/services',
        hash_including(
          service: {
            name: 'dummy',
            hostname: 'http://dummy.com',
            port: '80'
          }
        )
      )

      ActiveSpy.register_service
    end

    it 'should not register itself if already registrated' do
      response = double('response')
      expect(response).to receive(:code).and_return(200)

      expect(RestClient).to receive(:get).
        with('http://event-runner.com:443/services/dummy').and_return(response)

      ActiveSpy.register_service
    end

    context 'hooks management' do
      it 'should check if the hooks are in sync with event runner' do
        ActiveSpy::Rails::HookList.clear
        hooks = {
          'hooks' => [
            {
              'class' => 'Product',
              'postPath' => '/notifications/product',
              'active' => true
            }
          ]
        }

        expect(RestClient).to receive(:get).with(
          'http://event-runner.com:443/services/dummy',
          ).and_return(hooks.to_json)

        class ProductListener < ActiveSpy::Rails::Listener
        end

        ActiveSpy::Rails::HookList.register
      end

      it 'should delete hooks that are not needed anymore' do
        ActiveSpy::Rails::HookList.clear
        hooks = {
          'hooks' => [
            {
              'id' => '1',
              'class' => 'Product',
              'postPath' => '/notifications/product',
              'active' => true
            }
          ]
        }

        expect(RestClient).to receive(:get).with(
          'http://event-runner.com:443/services/dummy',
        ).and_return(hooks.to_json)

        expect(RestClient).to receive(:delete).with(
          'http://event-runner.com:443/services/dummy/hooks/1',
        )

        ActiveSpy::Rails::HookList.register
      end

      it 'should add hooks that are not in event runner yet' do
        ActiveSpy::Rails::HookList.clear

        expect(RestClient).to receive(:get).with(
          'http://event-runner.com:443/services/dummy',
        ).and_return({'hooks' => []}.to_json)

        expect(RestClient).to receive(:post).with(
          'http://event-runner.com:443/services/dummy/hooks', {
            'class' => 'User',
            'postPath' => '/active_spy/notifications/user',
            'active' => true
          }
        )

        class UserListener < ActiveSpy::Rails::Listener
        end

        ActiveSpy::Rails::HookList.register
      end
    end
  end
end
