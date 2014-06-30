require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ActiveEvent::Spy do

  it 'should be able to watch on methods' do

    # Dummy event handler for the spec
    #
    class FooEvents < ActiveEvent::Base
      def before_bar
      end
    end

    # Dummy class to watch methods in the spec
    #
    class Foo
      include ActiveEvent::Spy
      watch_method :bar

      def bar
      end
      # watch_method :initialize
    end

    ActiveEvent::SpyList.activate

    expect_any_instance_of(FooEvents).to receive(:before_bar).and_call_original

    foo = Foo.new
    foo.bar
  end

end
