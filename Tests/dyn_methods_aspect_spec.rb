require 'rspec'

describe 'Dynamic methods aspect' do
  before :each do
    require_relative '../AOP-Framework/AOPFramework'

    class Foo3
      attr_accessor :joe,:lara

      def another
      end
      def other(sth)
      end
      def not_true
      end
      def not_false
      end

    end

    class Bar3 < Foo3
      attr_accessor :mar

      def moisture
      end
      def tomastee(colon)
      end
      def multiply(a,b)
      end
    end

    class NotFoo3
      def not_a_Foo_method
      end
    end
    @aspect=Aspect.new
    @foo=Foo3.new
    @aspect.pointcut =(Pointcut_Builder.new.class_array([Foo3,Bar3,NotFoo3]).method_start_with("not").build)
  end

  it 'should seCumple? metodo' do
    @aspect.pointcut.seCumple?(@foo.method(:not_true)).should == true
    @aspect.pointcut.seCumple?(@foo.method(:another)).should == false
  end

  it 'should seCumple? on dyn method' do
    class Foo3
      def not_harry_potter
      end
    end
    @aspect.pointcut.seCumple?(@foo.method(:not_harry_potter)).should == true
  end

  it 'should wrap dyn method' do
    @aspect.add_behaviour(:instead, lambda{|m,old_m,*args| 999})
    @foo.not_true.should == 999
    Foo3.class_eval do
      define_method :not_harry_potter2 do
        100
      end
    end
   @foo.not_harry_potter2.should == 999
  end

end