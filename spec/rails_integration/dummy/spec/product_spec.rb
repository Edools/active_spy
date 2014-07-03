require 'spec_helper'

describe Product do

  it 'should send itself to a event-runner instance' do
    right_now = Time.now
    product = Product.new name: 'Foo', id: 1, created_at: right_now,
      updated_at: right_now

    ActiveEvent::Configuration.instance_eval do
      host 'http://google.com'
      port '80'
    end

    actor = double('actor')
    expect(actor).to receive(:to_actor)
    expect_any_instance_of(Product).to receive(:actor).and_return(actor)

    product.actor = actor

    expect(RestClient).to receive(:post).with('http://google.com:80',
      hash_including(
        event: {
          payload: {
            product: product.attributes,
            action: 'save'
          },
          realm: product.realm,
          actor: actor,
          type: 'Product'
        }
      )
    )

    product.save

  end

end
