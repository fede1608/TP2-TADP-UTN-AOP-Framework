class Pointcut
  attr_accessor :clases,:metodos,:builder,:seCumple
  attr_accessor :pointcuts_1,:pointcuts_2
  def initialize
    @clases=[]
    @metodos=[]
    @builder=nil
    @seCumple=nil
  end

  def seCumple?(metodo)
    @seCumple.call(metodo)
  end

  def and(otroPC)
    pc_and=Pointcut.new
    pc_and.clases=(@clases.select{|clase| otroPC.clases.include?(clase) })
    pc_and.metodos=(@metodos.select{|met| otroPC.metodos.map{|met| met.inspect}.include?(met.inspect)})
    pc_and.pointcuts_1=(self)
    pc_and.pointcuts_2=(otroPC)
    pc_and.seCumple=lambda{|metodo|  pc_and.pointcuts_1.seCumple?(metodo)  && pc_and.pointcuts_2.seCumple?(metodo)}
    pc_and
  end


  def or(otroPC)
    pc_or=Pointcut.new
    pc_or.clases=(@clases)
    (pc_or.clases << otroPC.clases).flatten!.uniq!
    pc_or.metodos=(@metodos)
    otroPC.metodos.each{|met| pc_or.metodos.push(met) if !pc_or.metodos.map{|met| met.inspect}.include?(met.inspect) && !met.name.to_s.start_with?('aopF_')}
    pc_or.pointcuts_1=(self)
    pc_or.pointcuts_2=(otroPC)
    pc_or.seCumple=lambda{|metodo|  pc_or.pointcuts_1.seCumple?(metodo)  || pc_or.pointcuts_2.seCumple?(metodo)}
    pc_or
  end
  #def || other TODO:TIRA ERROR SINTACTICO
  #  self.or(other)
  #end

  def not
    pc_not=Pointcut.new
    metodos_cls = []
    Object.subclasses.each  do |klass|
      metodos_cls << klass.instance_methods(false).map{|met| klass.instance_method(met)}.select{|metodo|  !(seCumple.call(metodo))}
    end
    pc_not.metodos = metodos_cls.flatten.compact
    pc_not.metodos.each do |metodo|
      pc_not.clases.push(metodo.owner)
    end
    pc_not.clases.uniq!
    pc_not.pointcuts_1=(self)
    pc_not.seCumple=(lambda{|metodo|  !self.seCumple?(metodo)})
    pc_not
  end

  alias_method :|, :or
  alias_method :&, :and
  #alias_method :!, :not
end
