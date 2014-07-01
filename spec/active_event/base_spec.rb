require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActiveEvent::Base do

  it 'should initialize with the related object' do
    base = ActiveEvent::Base.new double('object')
    object = base.instance_eval { @object }
    expect(object).not_to be_nil
  end

end
