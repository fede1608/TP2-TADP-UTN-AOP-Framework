require 'rspec'



describe 'Point Cuts' do

  before :each do
    require_relative '../AOP-Framework/AOPFramework'

    class Foo
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

    class Bar < Foo
      attr_accessor :mar

      def moisture
      end

      def tomastee(colon)
      end

      def multiply(a,b)
      end
    end

    class NotFoo
      def not_a_Foo_method

      end
    end

    @aspect=Aspect.new

   ##hardcodeo para q no interfieran las clases del Rspec
   # class Object
    #   def self.inherited(subclass)
    #   end
    # end

  end

  it 'class array point cut' do
    @aspect.pointcut=(Pointcut_Builder.new.class_array([NotFoo]).build)
    @aspect.pointcut.metodos.map{|m| m.name}.should include(:not_a_Foo_method)
    @aspect.pointcut.should have(1).metodos
    @aspect.pointcut.clases.should include(NotFoo)
    @aspect.pointcut.should have(1).clases
  end

  it 'accessors point cut' do
    @aspect.pointcut =(Pointcut_Builder.new.class_array([Foo,Bar]).method_accessor(true).build)
    @aspect.pointcut.metodos.map{|m| m.name}.should include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    @aspect.pointcut.should have(6).metodos
  end

  it 'class hierarchy point cut' do
    @aspect.pointcut =(Pointcut_Builder.new.class_hierarchy(Bar).build)
    @aspect.pointcut.metodos.map{|m| m.name}.should include(*Foo.instance_methods(false))
    @aspect.pointcut.metodos.map{|m| m.name}.should include(*Bar.instance_methods(false))
    @aspect.pointcut.should have(13).metodos
    @aspect.pointcut.clases.should include(Foo,Bar)
    @aspect.pointcut.should have(2).clases
  end

  it 'method arity point cut' do
    @aspect.pointcut=(Pointcut_Builder.new.class_array([Foo,Bar]).method_arity(1).build)
    @aspect.pointcut.metodos.map{|m| m.name}.should include(:tomastee,:other,:joe=,:lara=,:mar=)
    @aspect.pointcut.should have(5).metodos
  end

  it 'method array point cut' do
    @aspect.pointcut=(Pointcut_Builder.new.method_array([:multiply]).build)
    @aspect.pointcut.metodos.map{|m| m.name}.should include(:multiply)
    @aspect.pointcut.should have(1).metodos
  end

  it 'class childs point cut' do
    @aspect.pointcut=(Pointcut_Builder.new.class_childs(Foo).build)
    @aspect.pointcut.metodos.map{|m| m.name}.should include(:moisture,:tomastee,:multiply,:mar,:mar=)
    @aspect.pointcut.should have(5).metodos
    @aspect.pointcut.clases.should include(Bar)
    @aspect.pointcut.should have(1).clases
  end

  it '' do
    @aspect.pointcut=(Pointcut_Builder.new..build)
    @aspect.pointcut.metodos.map{|m| m.name}.should include()
    @aspect.pointcut.should have().metodos
    @aspect.pointcut.clases.should include()
    @aspect.pointcut.should have().clases
  end
end