require 'rspec'

describe 'Operar logicamente con PointCuts' do
  before :each do
    require_relative '../AOP-Framework/AOPFramework'
    Object.subclasses.clear
    class Foo7
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

    class Bar7 < Foo7
      attr_accessor :mar

      def moisture
      end

      def tomastee(colon)
      end

      def multiply(a,b)
      end
    end

    class NotFoo7
      def not_a_Foo_method

      end
    end

    @aspect=Aspect.new
  end
  after do
    Object.send :remove_const, :Foo7
    Object.send :remove_const, :Bar7
    Object.send :remove_const, :NotFoo7
  end

  it 'should OR 2 pointcuts' do
    pc1=(Pointcut_Builder.new.class_array([Foo7,Bar7]).method_accessor(true).build)
    pc1.metodos.map{|m| m.name}.should include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    pc1.should have(6).metodos
    pc2=(Pointcut_Builder.new.class_array([Foo7,Bar7]).method_arity(1).build)
    pc2.metodos.map{|m| m.name}.should include(:tomastee,:other,:joe=,:lara=,:mar=)
    pc2.should have(5).metodos
    @aspect.pointcut =(pc1.or(pc2))
    @aspect.pointcut.metodos.map{|m| m.name}.should include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    @aspect.pointcut.metodos.map{|m| m.name}.should include(:tomastee,:other,:joe=,:lara=,:mar=)
    @aspect.pointcut.should have(8).metodos
  end

  it 'should AND 2 pointcuts' do
    pc1=(Pointcut_Builder.new.class_array([Foo7,Bar7]).method_accessor(true).build)
    pc1.metodos.map{|m| m.name}.should include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    pc1.should have(6).metodos
    pc2=(Pointcut_Builder.new.class_array([Foo7,Bar7]).method_arity(1).build)
    pc2.metodos.map{|m| m.name}.should include(:tomastee,:other,:joe=,:lara=,:mar=)
    pc2.should have(5).metodos
    @aspect.pointcut =(pc1.and(pc2))
    @aspect.pointcut.metodos.map{|m| m.name}.should include(:joe=,:lara=,:mar=)
    @aspect.pointcut.should have(3).metodos
  end

  it 'should Negate(NOT) a pointcut' do
    pc1=(Pointcut_Builder.new.class_array([Foo7,Bar7]).method_accessor(true).build)
    #pc1.metodos.map{|m| m.name}.should include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    #pc1.should have(6).metodos
    @aspect.pointcut=(pc1.not)
    @aspect.pointcut.metodos.map{|m| m.name}.should include(:tomastee,:other,:not_true,:not_false,:not_a_Foo_method,:another,:moisture,:multiply)
    @aspect.pointcut.metodos.map{|m| m.name}.should_not include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
  end

  it 'should AND & OR mixed' do
    pc1=(Pointcut_Builder.new.class_array([Foo7,Bar7]).method_accessor(true).build)
    pc1.metodos.map{|m| m.name}.should include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    pc1.should have(6).metodos
    pc2=(Pointcut_Builder.new.class_array([Foo7,Bar7]).method_arity(1).build)
    pc2.metodos.map{|m| m.name}.should include(:tomastee,:other,:joe=,:lara=,:mar=)
    pc2.should have(5).metodos
    @aspect.pointcut =(pc1.and(pc2.or(pc1)))#A and (B or A) = A
    @aspect.pointcut.metodos.map{|m| m.name}.should include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    @aspect.pointcut.should have(6).metodos
  end

  it 'should NOT & AND mixed' do
    pc1=(Pointcut_Builder.new.class_array([Foo7,Bar7,NotFoo7]).method_accessor(true).build)
    pc1.metodos.map{|m| m.name}.should include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    pc1.should have(6).metodos
    @aspect.pointcut =(pc1.not.and(Pointcut_Builder.new.class_array([Foo7,Bar7,NotFoo7]).build))
    @aspect.pointcut.metodos.map{|m| m.name}.should include(:tomastee,:other,:not_true,:not_false,:not_a_Foo_method,:another,:moisture,:multiply)
    @aspect.pointcut.metodos.map{|m| m.name}.should_not include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    @aspect.pointcut.should have(8).metodos
  end
end