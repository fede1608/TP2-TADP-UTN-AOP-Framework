require 'rspec'

require_relative '../AOP-Framework/pointcut_builder'
require_relative '../AOP-Framework/pointcut_core'
require_relative '../AOP-Framework/object_class_custom'

describe 'Operar logicamente con PointCuts' do
  before :each do
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

  end
  after do
    Object.send :remove_const, :Foo7
    Object.send :remove_const, :Bar7
    Object.send :remove_const, :NotFoo7
    Object.subclasses.clear
  end

  it 'should OR 2 pointcuts' do
    pc1=(Pointcut_Builder.new.class_array([Foo7,Bar7]).method_accessor(true).build)
    pc1.metodos.map{|m| m.name}.should include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    pc1.should have(6).metodos
    pc2=(Pointcut_Builder.new.class_array([Foo7,Bar7]).method_arity(1).build)
    pc2.metodos.map{|m| m.name}.should include(:tomastee,:other,:joe=,:lara=,:mar=)
    pc2.should have(5).metodos
    pointcut_or =(pc1.or(pc2))
    pointcut_or.metodos.map{|m| m.name}.should include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    pointcut_or.metodos.map{|m| m.name}.should include(:tomastee,:other,:joe=,:lara=,:mar=)
    pointcut_or.should have(8).metodos
  end

  it 'should AND 2 pointcuts' do
    pc1=(Pointcut_Builder.new.class_array([Foo7,Bar7]).method_accessor(true).build)
    pc1.metodos.map{|m| m.name}.should include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    pc1.should have(6).metodos
    pc2=(Pointcut_Builder.new.class_array([Foo7,Bar7]).method_arity(1).build)
    pc2.metodos.map{|m| m.name}.should include(:tomastee,:other,:joe=,:lara=,:mar=)
    pc2.should have(5).metodos
    pointcut_and =(pc1.and(pc2))
    pointcut_and.metodos.map{|m| m.name}.should include(:joe=,:lara=,:mar=)
    pointcut_and.should have(3).metodos
  end

  it 'should Negate(NOT) a pointcut' do
    pc1=(Pointcut_Builder.new.class_array([Foo7,Bar7]).method_accessor(true).build)
    pc1.metodos.map{|m| m.name}.should include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    pc1.should have(6).metodos
    pointcut_not=(pc1.not)
    pointcut_not.metodos.map{|m| m.name}.should include(:tomastee,:other,:not_true,:not_false,:not_a_Foo_method,:another,:moisture,:multiply)
    pointcut_not.metodos.map{|m| m.name}.should_not include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
  end

  it 'should AND & OR mixed' do
    pc1=(Pointcut_Builder.new.class_array([Foo7,Bar7]).method_accessor(true).build)
    pc1.metodos.map{|m| m.name}.should include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    pc1.should have(6).metodos
    pc2=(Pointcut_Builder.new.class_array([Foo7,Bar7]).method_arity(1).build)
    pc2.metodos.map{|m| m.name}.should include(:tomastee,:other,:joe=,:lara=,:mar=)
    pc2.should have(5).metodos
    pointcut_and_or =pc1 & (pc2 | pc1) #A and (B or A) = A
    pointcut_and_or.metodos.map{|m| m.name}.should include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    pointcut_and_or.should have(6).metodos
  end

  it 'should NOT & AND mixed' do
    pc1=(Pointcut_Builder.new.class_array([Foo7,Bar7,NotFoo7]).method_accessor(true).build)
    pc1.metodos.map{|m| m.name}.should include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    pc1.should have(6).metodos
    pc2= Pointcut_Builder.new.class_array([Foo7,Bar7,NotFoo7]).build
    pointcut_and_not= (pc1.!) & pc2
    pointcut_and_not.metodos.map{|m| m.name}.should include(:tomastee,:other,:not_true,:not_false,:not_a_Foo_method,:another,:moisture,:multiply)
    pointcut_and_not.metodos.map{|m| m.name}.should_not include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    pointcut_and_not.should have(8).metodos
  end
end