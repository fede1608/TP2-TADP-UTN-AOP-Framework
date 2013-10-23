require 'rspec'

require_relative '../AOP-Framework/pointcut_builder'
require_relative '../AOP-Framework/pointcut_core'
require_relative '../AOP-Framework/object_class_custom'


describe 'Point Cuts' do

  before :each do
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

    class Foo8
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

    class Bar8 < Foo8
      attr_accessor :mar

      def moisture
      end

      def tomastee(colon)
      end

      def multiply(a,b)
      end
    end

    class Fight8 < Foo8
      attr_accessor :sol

      def moisture2
      end

      def tomastee2(colon)
      end

    end



   ##hardcodeo para q no interfieran las clases del Rspec
   # class Object
    #   def self.inherited(subclass)
    #   end
    # end

  end
  after do
    Object.send :remove_const, :Foo8
    Object.send :remove_const, :Fight8
    Object.send :remove_const, :Foo
    Object.send :remove_const, :Bar
    Object.send :remove_const, :Bar8
    Object.send :remove_const, :NotFoo
    Object.subclasses.clear
  end

  it 'class array point cut' do
    pointcut=(Pointcut_Builder.new.class_array([NotFoo]).build)
    pointcut.metodos.map{|m| m.name}.should include(:not_a_Foo_method)
    pointcut.should have(1).metodos
    pointcut.clases.should include(NotFoo)
    pointcut.should have(1).clases
  end

  it 'accessors point cut' do
    pointcut =(Pointcut_Builder.new.class_array([Foo,Bar]).method_accessor(true).build)
    pointcut.metodos.map{|m| m.name}.should include(:joe,:lara,:mar,:joe=,:lara=,:mar=)
    pointcut.should have(6).metodos
  end

  it 'class hierarchy point cut' do
    pointcut =(Pointcut_Builder.new.class_hierarchy(Bar).build)
    pointcut.metodos.map{|m| m.name}.should include(*Foo.instance_methods(false))
    pointcut.metodos.map{|m| m.name}.should include(*Bar.instance_methods(false))
    pointcut.should have(13).metodos
    pointcut.clases.should include(Foo,Bar)
    pointcut.should have(2).clases
  end

  it 'method arity point cut' do
    pointcut=(Pointcut_Builder.new.class_array([Foo,Bar]).method_arity(1).build)
    pointcut.metodos.map{|m| m.name}.should include(:tomastee,:other,:joe=,:lara=,:mar=)
    pointcut.should have(5).metodos
  end

  it 'method array point cut' do
    pointcut=(Pointcut_Builder.new.class_array([Foo,Bar]).method_array([:multiply]).build)
    pointcut.metodos.map{|m| m.name}.should include(:multiply)
    pointcut.should have(1).metodos
  end

  it 'class childs point cut' do
    pointcut=(Pointcut_Builder.new.class_childs(Foo).build)
    pointcut.metodos.map{|m| m.name}.should include(:moisture,:tomastee,:multiply,:mar,:mar=)
    pointcut.should have(5).metodos
    pointcut.clases.should include(Bar)
    pointcut.should have(1).clases
  end

  it 'class childs, class start and method start with point cut' do
    pointcut = (Pointcut_Builder.new.class_childs(Foo8).class_start_with("Fi").method_start_with("mois").build)
    pointcut.metodos.map{|m| m.name}.should include(:moisture2)
    pointcut.should have(1).metodos
    pointcut.clases.should include(Fight8)
    pointcut.should have(1).clases
  end

  it 'class hierarchy and method_arity point cut' do
    pointcut = (Pointcut_Builder.new.class_hierarchy(Fight8).method_arity(1).build)
    pointcut.metodos.map{|m| m.name}.should include(:tomastee2,:other,:joe=,:lara=,:sol=)
    pointcut.should have(5).metodos
    pointcut.clases.should include(Fight8,Foo8)
    pointcut.should have(2).clases
  end

  it 'class hierarchy, method_arity and method accessors point cut' do
    pointcut = (Pointcut_Builder.new.class_hierarchy(Fight8).method_arity(1).method_accessor(false).build)
    pointcut.metodos.map{|m| m.name}.should include(:tomastee2,:other)
    pointcut.should have(2).metodos
    pointcut.clases.should include(Fight8,Foo8)
    pointcut.should have(2).clases
  end

  it 'class array, class regex and method accessor point cut' do
    pointcut = (Pointcut_Builder.new.class_array([Foo8,Bar8,Fight8]).class_regex(/[ai]/).method_accessor(false).build)
    pointcut.metodos.map{|m| m.name}.should include(:moisture,:multiply,:tomastee,:moisture2,:tomastee2)
    pointcut.should have(5).metodos
    pointcut.clases.should include(Bar8,Fight8)
    pointcut.should have(2).clases
  end

  it 'class array, class regex, method accessor and method array point cut' do
    pointcut = (Pointcut_Builder.new.class_array([Foo8,Bar8,Fight8]).class_regex(/[ai]/).method_accessor(false).method_array([:moisture,:moisture2]).build)
    pointcut.metodos.map{|m| m.name}.should include(:moisture,:moisture2)
    pointcut.should have(2).metodos
    pointcut.clases.should include(Bar8,Fight8)
    pointcut.should have(2).clases
  end

  it 'class array and method regex point cut' do
    pointcut = (Pointcut_Builder.new.class_array([Bar8,Fight8]).method_regex(/ist...2/).build)
    pointcut.metodos.map{|m| m.name}.should include(:moisture2)
    pointcut.should have(1).metodos
    pointcut.clases.should include(Bar8,Fight8)
    pointcut.should have(2).clases
  end

  it 'method block pointcut' do
    pointcut=(Pointcut_Builder.new.method_block(lambda {|metodo| metodo.owner==NotFoo}).build)
    pointcut.metodos.map{|m| m.name}.should include(:not_a_Foo_method)
    pointcut.should have(1).metodos
  end

  #it '' do
  #  pointcut=(Pointcut_Builder.new..build)
  #  pointcut.metodos.map{|m| m.name}.should include()
  #  pointcut.should have().metodos
  #  pointcut.clases.should include()
  #  pointcut.should have().clases
  #end
end