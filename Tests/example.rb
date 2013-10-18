require_relative '../AOP-Framework/AOPFramework'

class Foo
  attr_accessor :algo,:otro

  def heavy
    10000.times do
      Math.sqrt(1000)
    end
  end
end
class Bar < Foo
end

aspecto=Aspect.new
p aspecto.pointcut=(aspecto.builder.class_array([Foo,Bar]).method_arity(0).build)
aspecto.add_behaviour(:before, lambda {|met,*arguments|@start_time = Time.now;})
aspecto.add_behaviour(:after, lambda {|met,res|  puts (Time.now - @start_time).to_s + " have elapsed"; puts "El resultado fue #{res.to_s}"})
aspecto.logging


p Foo.new.algo
p Foo.new.heavy
p Foo.new.method(:otro).parameters

class Hola
  attr_accessor :algo2,:otro2

  def shit
    raise('un error')
  end
  def hello(world=1,bye=0)
    #example parameter name
  end
end
class Chau < Hola
end
aspecto2=Aspect.new
aspecto2.pointcut=(aspecto2.builder.class_hierarchy(Chau).method_arity(0).build)
aspecto2.add_behaviour(:on_error,lambda {|metodo, e| a= metodo.receiver.instance_variables;  p metodo.receiver.instance_variable_get(a[0]); p e.to_s })

a=Hola.new
a.otro2=(7)
a.shit
p a.otro2
p a.method(:hello).parameters.map(&:last).map(&:to_s)
p a.method(:hello).parameters.map(&:first)
p a.method(:hello).parameters

#example parameter name
aspecto3=Aspect.new
aspecto3.pointcut =(Pointcut_Builder.new.method_parameter_name("world").build)
p aspecto3.pointcut.clases
p aspecto3.pointcut.metodos

#example parameter type
aspecto4=Aspect.new
aspecto4.pointcut =(Pointcut_Builder.new.method_parameters_type(:opt_all).build)
p aspecto4.pointcut.clases
p aspecto4.pointcut.metodos
