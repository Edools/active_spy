require 'spec_helper'

describe Product do

  it 'should send itself to a event-runner instance' do
    right_now = Time.now
    product = Product.new name: 'Foo', id: 1, guid: '123', created_at: right_now,
      updated_at: right_now

    ActiveEvent::Configuration.instance_eval do
      host 'http://google.com'
      port '80'
    end

    expect(RestClient).to receive(:post).with('http://google.com:80/',
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
    expect(product.realm).to eql('my realm')
  end

  context 'service registration' do
    before(:each) do
      ActiveEvent::Configuration.instance_eval do
        name 'service-name'
        host 'http://google.com'
        port '80'
        event_host 'http://event.com'
        event_port '443'
      end
    end

    it 'should register service when register_service is called' do
      response = double('response')
      expect(response).to receive(:code).and_return(404)

      expect(RestClient).to receive(:get).
        with('http://event.com:443/services/service-name').and_return(response)

      expect(RestClient).to receive(:post).with('http://event.com:443/services',
        hash_including(
          service: {
            name: 'service-name',
            hostname: 'http://google.com',
            port: '80'
          }
        )
      )

      ActiveEvent.register_service
    end

    it 'should not register itself if already registrated' do
      response = double('response')
      expect(response).to receive(:code).and_return(200)

      expect(RestClient).to receive(:get).
        with('http://event.com:443/services/service-name').and_return(response)

      ActiveEvent.register_service
    end
  end
end
