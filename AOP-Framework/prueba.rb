require_relative('../AOP-Framework/AOPModule')



class Foo
end

class Foo2
end

class Bar
end

class Hola

end

class Chau < Hola
end

aop=AOPFramework.new

clase_proc= lambda {|clase| true}
metodo_proc=lambda {|metodo| true}
p aop.point_cut(clase_proc,metodo_proc)

p AOPFramework.instance_methods(false)