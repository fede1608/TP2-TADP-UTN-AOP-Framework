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
  attr_accessor :algo,:otro

  def shit
    raise('un error')
  end
end
class Chau < Hola
end
aspecto2=Aspect.new
aspecto2.pointcut=(aspecto2.builder.class_hierarchy(Chau).method_arity(0).build)
aspecto2.add_behaviour(:on_error,lambda {|metodo, e| a= metodo.receiver.instance_variables;  p metodo.receiver.instance_variable_get(a[0]); p e.to_s })

a=Hola.new
a.otro=(7)
a.shit
p a.otro


class Foo2
  attr_accessor :algo,:otro

  def heavy
    self.algo
  end
end
class Bar2 < Foo2
end

cacheAspecto=Aspect.new
cacheAspecto.pointcut=(cacheAspecto.builder.class_array([Foo2,Bar2]).build)
cacheAspecto.logging
cacheAspecto.pointcut.and!(cacheAspecto.builder.class_array([Foo2,Bar2]).method_accessor(true).build.not!(:metodo))
cacheAspecto.add_behaviour(:before, lambda {|metodo, *args| if metodo.receiver.algo == 5; metodo.receiver.otro=75; raise "error";  end})
cacheAspecto.add_behaviour(:on_error,lambda{|met, e|  met.receiver.otro })


a=Foo2.new
a.algo=(6)
p a.heavy
a.algo=(5)
p a.heavy
a.algo=(55)
p a.heavy

