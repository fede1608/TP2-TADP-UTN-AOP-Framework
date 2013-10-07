require_relative('../AOP-Framework/AOPModule')



class Foo
  attr_accessor :un_accessor, :otro_accessor
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
p aop.point_cut_regexp(/[o]/,/clase/)
p aop.point_cut_regexp_clase(/[o]/)
p aop.point_cut_regexp_metodos(/[o]/)
p aop.point_cut_accessors( lambda {|clase| true} )

