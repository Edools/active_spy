require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ActiveEvent::Spy do

  it 'should be able to watch on methods' do

    class FooEvents < ActiveEvent::Base
      def before_bar
      end
    end

    class Foo
      include ActiveEvent::Spy

      def bar
      end
      watch_method :bar
      # watch_method :initialize
    end

    # ActiveEvent::SpiesList.instance.active_all

    expect_any_instance_of(FooEvents).to receive(:before_bar).and_call_original

    foo = Foo.new
    foo.bar
  end


end
