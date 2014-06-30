require 'spec_helper'

describe User do

  it 'should update the name before save' do
    ActiveEvent::SpyList.activate
    user = User.new name: 'Foo'

    expect_any_instance_of(UserEvents).to receive(:before_save).and_call_original

    user.save
  end

end
