require_relative '../AOP-Framework/AOPFramework'

class Foo2
  attr_accessor :algo,:otro

  def heavy(number)
    p "metodo original"
    number*@algo
  end
  def heavy2(number,number2)
    p "metodo original"
    number*number2
  end
end
class Bar2 < Foo2
end

cacheAspecto=Aspect.new
#cacheAspecto.dyn_methods =false
cacheAspecto.pointcut=(cacheAspecto.builder.class_array([Foo2,Bar2]).build)
cacheAspecto.pointcut=(cacheAspecto.pointcut.and(Pointcut_Builder.new.class_array([Foo2,Bar2]).method_accessor(true).build.not))
cacheAspecto.add_behaviour(:before, lambda do |metodo, *args|
  p metodo.receiver.instance_variable_get("@cache_res_hash")
  state=Hash[]
  metodo.receiver.instance_variables.each do |sym|
    state[sym]=metodo.receiver.instance_variable_get(sym) unless sym.to_s.start_with?("@cache")
  end
  argument=Hash[:args=>metodo.receiver.instance_variable_get("@cache_args"), :state=>state]
  p argument
  if !metodo.receiver.instance_variable_get("@cache_res_hash")[metodo.name].nil? and !metodo.receiver.instance_variable_get("@cache_res_hash")[metodo.name][argument].nil?
    metodo.receiver.instance_variable_set("@cache_res",metodo.receiver.instance_variable_get("@cache_res_hash")[metodo.name][argument])
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
  state=Hash[]
  metodo.receiver.instance_variables.each do |sym|
    state[sym]=metodo.receiver.instance_variable_get(sym) unless sym.to_s.start_with?("@cache")
  end
  argument=Hash[:args=>metodo.receiver.instance_variable_get("@cache_args"), :state=>state]
  p argument
  metodo.receiver.instance_variable_get("@cache_res_hash")[metodo.name][argument] = res
end)

cacheAspecto.add_behaviour(:on_error,lambda do |metodo, e|
  p "metodo cacheado"
  metodo.receiver.instance_variable_get("@cache_res")
end)
cacheAspecto.pointcut=(cacheAspecto.builder.class_array([Foo2,Bar2]).build)
cacheAspecto.logging


a=Foo2.new
a.instance_variable_set("@cache_res_hash",Hash[])

a.algo =(5)
 a.heavy(3)
 a.heavy(3)
a.algo =(6)
 a.heavy(3)
 a.heavy(3)
a.algo =(5)
 a.heavy(3)
a.algo =(6)
 a.heavy(3)

#
#p a.heavy(4)
#p a.heavy2(3,6)
#p a.heavy2(3,8)
#p a.heavy2(3,6)
#p a.heavy(3)
#
#
#a.otro =(7)

