require_relative('../AOP-Framework/AOPModule')



class Foo
  attr_accessor :un_accessor, :otro_accessor
end

class Foo2
end

class Bar
  def methodd(par1,par2)

  end
  def methodd1(par1)

  end
end

class Hola
  attr_accessor :un_accessor2, :otro_accessor2
end

class Chau < Hola
end

aop=AOPFramework.new

clase_proc= lambda {|clase| true}
metodo_proc=lambda {|metodo| true}
p aop.point_cut(clase_proc,metodo_proc)
p aop.point_cut_bloque_clase(clase_proc)
p aop.point_cut_bloque_metodo(metodo_proc)
p aop.point_cut_regexp(/[o]/,/clase/)
p aop.point_cut_regexp_clase(/[o]/)
p aop.point_cut_regexp_metodos(/[o]/)
p aop.point_cut_accessors()
p aop.point_cut_method_start_with("point_cut_reg")
p aop.point_cut_hierarchy(Chau)
p aop.point_cut_array_clase([Foo,Bar,Chau])
p aop.point_cut_array_metodos([:point_cut,:otro_accessor])
p aop.point_cut_array_metodos(["point_cut","otro_accessor"])
p aop.point_cut_metodos_arity(2)
p aop.point_cut_OR(aop.point_cut_hierarchy(Chau),aop.point_cut_array_metodos(["point_cut","otro_accessor"]))
p aop.point_cut_AND(aop.point_cut_array_clase([Bar]),aop.point_cut_metodos_arity(1))
p aop.point_cut_OR(aop.point_cut_AND(aop.point_cut_array_clase([Bar]),aop.point_cut_metodos_arity(1)),aop.point_cut_accessors())
p aop.point_cut_class_NOT(aop.point_cut_hierarchy(Chau))
p aop.point_cut_metodo_NOT(aop.point_cut_AND(aop.point_cut_array_clase([Bar]),aop.point_cut_metodos_arity(2)))