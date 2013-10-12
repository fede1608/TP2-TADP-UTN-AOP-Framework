require_relative '../AOP-Framework/AOPFramework'

pcb=Pointcut_Builder.new
p  Pointcut_Builder.instance_methods(false)
class Foo; end; class Bar < Foo; end
p pcb.class_array([Foo,Bar]).method_arity(6).build.clases
