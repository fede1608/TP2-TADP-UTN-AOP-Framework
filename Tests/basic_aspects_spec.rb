require 'rspec'

describe 'Basic Aspects' do


  before :each do
    require_relative '../AOP-Framework/AOPFramework'
    class Foo
      attr_accessor :algo,:otro
      def initialize
        @algo=4
        @otro=7
      end
      def heavy
        10000.times do
          Math.sqrt(1000)
      end
      end
    end
    class Bar < Foo
      def shit
        raise('un error')
      end
    end
    class Object
      def self.inherited(subclass)
      end
    end

    @foo=Foo.new
    @bar=Bar.new

  end

  it 'should aspect before' do
    beforeAspect=Aspect.new
    beforeAspect.pointcut =(Pointcut_Builder.new.method_arity(1).build)
    beforeAspect.add_behaviour(:before,lambda{|met,*args| met.receiver.instance_variable_set(:@algo,*args) })
    @foo.otro=(-1)
    @foo.algo.should ==  -1
  end

  it 'should aspect after' do
    afterAspect=Aspect.new
    afterAspect.pointcut =(Pointcut_Builder.new.method_array([:heavy]).build)
    afterAspect.add_behaviour(:after,lambda{|met,res| met.receiver.instance_variable_set(:@algo,res) })
    @foo.heavy
    @foo.algo.should ==  10000
  end

  it 'should aspect instead' do
    errorAspect=Aspect.new
    errorAspect.pointcut =(Pointcut_Builder.new.build)
    @foo.algo.should ==  4
    errorAspect.add_behaviour(:instead,lambda{|met,old_met,*args| 90})
    @foo.algo.should ==  90
  end

  it 'should aspect on error' do
    errorAspect=Aspect.new
    errorAspect.pointcut =(Pointcut_Builder.new.build)
    errorAspect.add_behaviour(:on_error,lambda{|met,e| e})
    @bar.shit.should_not  raise_exception
  end
end