require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActiveSpy::Spy do

  # Dummy event handler for the spec
  #
  class FooEvents < ActiveSpy::Base
    def before_bar
    end

    def after_bar
    end

    def before_foo
    end

    def after_foo
    end
  end

  # Dummy class to watch methods in the spec
  #
  class Foo
    include ActiveSpy::Spy
    watch_method :bar, :foo

    def bar
      'truthy'
    end

    def foo
      'I was called'
    end
  end

  it 'should be able to watch on methods' do
    ActiveSpy::SpyList.activate

    expect_any_instance_of(FooEvents).to receive(:before_bar).and_call_original
    expect_any_instance_of(FooEvents).to receive(:after_bar).and_call_original

    expect_any_instance_of(FooEvents).to receive(:before_foo).and_call_original
    expect_any_instance_of(FooEvents).to receive(:after_foo).and_call_original

    foo = Foo.new
    foo.bar
    expect(foo.foo).to eql('I was called')
  end

  it 'should be able to deactive itself' do
    ActiveSpy::SpyList.activate
    ActiveSpy::SpyList.deactivate

    expect_any_instance_of(FooEvents).not_to receive(:before_foo)
    expect_any_instance_of(FooEvents).not_to receive(:after_foo)

    foo = Foo.new
    expect(foo.foo).to eql('I was called')
  end

end
