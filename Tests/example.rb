require_relative '../AOP-Framework/AOPFramework'

class Foo
  attr_accessor :algo,:otro
end
class Bar < Foo
end

aspecto=Aspect.new
p aspecto.pointcut=(aspecto.builder.class_array([Foo,Bar]).method_arity(0).build)
aspecto.add_behaviour(lambda {|met,*arguments| puts "Se utilizo el metodo #{met.name.to_s} y se recibio los parametros #{arguments.to_s}"}, lambda{|res| start_time = Time.now; puts (Time.now - start_time).to_s + " have elapsed"; puts "El resultado fue #{res.to_s}"})
aspecto.logging

Foo.new.algo
Foo.new.otro
