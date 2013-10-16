require_relative '../AOP-Framework/AOPFramework'

class Foo2
  attr_accessor :algo,:otro

  def heavy(number)
    p "metodo original"
    number*3
  end
  def heavy2(number,number2)
    p "metodo original"
    number*number2
  end
end
class Bar2 < Foo2
end

cacheAspecto=Aspect.new
cacheAspecto.pointcut=(cacheAspecto.builder.class_array([Foo2,Bar2]).build)
cacheAspecto.logging
cacheAspecto.pointcut=(cacheAspecto.pointcut.and!(Pointcut_Builder.new.class_array([Foo2,Bar2]).method_accessor(true).build.not!))
cacheAspecto.add_behaviour(:before, lambda do |metodo, *args|
  p metodo.receiver.instance_variable_get("@cache_res_hash")
  if !metodo.receiver.instance_variable_get("@cache_res_hash")[metodo.name].nil? and !metodo.receiver.instance_variable_get("@cache_res_hash")[metodo.name][args].nil?
    metodo.receiver.instance_variable_set("@cache_res",metodo.receiver.instance_variable_get("@cache_res_hash")[metodo.name][args])
    raise ArgumentError ,"Encontro cache"
  else
    metodo.receiver.instance_variable_set("@cache_args", args)
  end
end)

cacheAspecto.add_behaviour(:after, lambda do |metodo, res|
  if metodo.receiver.instance_variable_get("@cache_res_hash").nil?
    metodo.receiver.instance_variable_set("@cache_res_hash",Hash[])
  end
  if metodo.receiver.instance_variable_get("@cache_res_hash")[metodo.name].nil?
    metodo.receiver.instance_variable_get("@cache_res_hash")[metodo.name] = Hash[]
  end
  metodo.receiver.instance_variable_get("@cache_res_hash")[metodo.name][metodo.receiver.instance_variable_get("@cache_args")] = res
end)

cacheAspecto.add_behaviour(:on_error,lambda do |metodo, e|
  p "metodo cacheado"
  metodo.receiver.instance_variable_get("@cache_res")
end)


a=Foo2.new
a.instance_variable_set("@cache_res_hash",Hash[])


p a.heavy(3)
p a.heavy(4)
p a.heavy2(3,6)
p a.heavy2(3,8)
p a.heavy2(3,6)
p a.heavy(3)

a.algo =(5)
a.otro =(7)
p a.inspect
