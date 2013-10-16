require_relative '../AOP-Framework/AOPFramework'

class Foo3
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
class Bar3 < Foo3
  attr_accessor :algo3,:otro3
end