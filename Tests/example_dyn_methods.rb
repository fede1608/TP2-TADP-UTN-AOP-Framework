require_relative '../AOP-Framework/AOPFramework'

class Foo3
  attr_accessor :algo,:otro,:otromas


  def heavy(number)
    if number==-1
      raise "error"
    end
    number*3
  end
  def heavy2(number,number2)
    number*number2
  end
end
class Bar3 < Foo3
  attr_accessor :algo3,:otro3
end

aspect=Aspect.new
aspect.pointcut =(Pointcut_Builder.new.method_accessor(true).build)
aspect.logging

foo=Foo3.new
foo.algo=(5)
foo.otro=("heeello_Worrld")

Foo3.class_eval do
  attr_accessor :dyn_accessor

  define_method :nada_que_ver do
    p "nothing"
  end
end

p foo.dyn_accessor=(3)
foo.nada_que_ver