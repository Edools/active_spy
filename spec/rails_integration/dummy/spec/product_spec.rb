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

  it 'should register service when register_service is called' do
    ActiveEvent::Configuration.instance_eval do
      name 'service-name'
      host 'http://google.com'
      port '80'
    end

    expect(RestClient).to receive(:post).with('http://google.com:80/',
      hash_including(
        service: {
          name: 'service-name',
          hostname: 'http://google.com',
          port: 80
        }
      )
    )
  end
end
