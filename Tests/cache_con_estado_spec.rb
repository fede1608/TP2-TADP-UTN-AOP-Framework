require 'rspec'

require_relative '../AOP-Framework/pointcut_builder'
require_relative '../AOP-Framework/pointcut_core'
require_relative '../AOP-Framework/aspect_core'
require_relative '../AOP-Framework/object_class_custom'

describe 'Cache con Estado' do
  before :each do
    class Foo5
      attr_accessor :algo,:otro

      def heavy0
        @otro
      end

      def heavy(number)
        number*@otro
      end
      def heavy2(number,number2)
        number*number2*@otro
      end
    end

    cacheAspecto=Aspect.new
    cacheAspecto.pointcut=(cacheAspecto.builder.class_array([Foo5]).build)
    cacheAspecto.pointcut=(cacheAspecto.pointcut.and(Pointcut_Builder.new.class_array([Foo5]).method_accessor(true).build.not))
    cacheAspecto.add_behaviour(:before, lambda do |metodo, *args|
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
      argument=Hash[:args=>args, :state=>state]
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
      metodo.receiver.instance_variable_get("@cache_res")
      Hash[:cached=>true,:res=>metodo.receiver.instance_variable_get("@cache_res")] #Solo para el test, para identificar resultados cacheados
    end)


    @a=Foo5.new

  end
  after do
    Object.send :remove_const, :Foo5
    Object.subclasses.clear
  end

  it 'should cachear metodos con 0 parametros' do
    @a.otro =(5)
    @a.heavy0.should == 5
    @a.heavy0.should == Hash[:cached=>true,:res=>5]
    @a.otro=(6)
    @a.heavy0.should == 6
    @a.heavy0.should == Hash[:cached=>true,:res=>6]
  end

  it 'should cachear metodos con 1 parametro sin importar el estado' do
    @a.otro=(3)
    @a.heavy(3).should == 9
    @a.heavy(3).should == Hash[:cached=>true,:res=>9]
    @a.otro=(4)
    @a.heavy(3).should_not == Hash[:cached=>true,:res=>9]
    @a.heavy(3).should == Hash[:cached=>true,:res=>12]
    @a.otro=(3)
    @a.heavy(3).should == Hash[:cached=>true,:res=>9]
  end

  it 'should cachear metodos con 2 parametros sin importar el estado' do
    @a.otro=(3)
    @a.heavy2(3,3).should == 27
    @a.heavy2(3,3).should == Hash[:cached=>true,:res=>27]
    @a.otro=(4)
    @a.heavy2(3,3).should_not == Hash[:cached=>true,:res=>27]
    @a.heavy2(3,3).should == Hash[:cached=>true,:res=>36]
    @a.heavy2(4,5).should == 80
    @a.otro=(0)
    @a.heavy2(4,5).should == 0
    @a.heavy2(4,5).should == Hash[:cached=>true,:res=>0]
  end


end