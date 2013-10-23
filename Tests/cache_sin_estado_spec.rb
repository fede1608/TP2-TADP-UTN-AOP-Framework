require 'rspec'

require_relative '../AOP-Framework/pointcut_builder'
require_relative '../AOP-Framework/pointcut_core'
require_relative '../AOP-Framework/aspect_core'
require_relative '../AOP-Framework/object_class_custom'

describe 'Cache Sin Estado' do

  before :each do
    class Foo4
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

    @cacheAspecto=Aspect.new
    @cacheAspecto.pointcut=(@cacheAspecto.builder.class_array([Foo4]).build)
    @cacheAspecto.pointcut=(@cacheAspecto.pointcut.and(@cacheAspecto.builder.class_array([Foo4]).method_accessor(true).build.not))
    @cacheAspecto.add_behaviour(:before, lambda do |metodo, *args|
      if metodo.receiver.instance_variable_get("@cache_res_hash").nil?
        metodo.receiver.instance_variable_set("@cache_res_hash",Hash[])
      end
      p metodo.receiver.instance_variable_get("@cache_res_hash")
      if !metodo.receiver.instance_variable_get("@cache_res_hash")[metodo.name].nil? and !metodo.receiver.instance_variable_get("@cache_res_hash")[metodo.name][args].nil?
        metodo.receiver.instance_variable_set("@cache_res",metodo.receiver.instance_variable_get("@cache_res_hash")[metodo.name][args])
        raise ArgumentError ,"Encontro cache"
      else
        metodo.receiver.instance_variable_set("@cache_args", args)
      end
    end)

    @cacheAspecto.add_behaviour(:after, lambda do |metodo, res|
      if metodo.receiver.instance_variable_get("@cache_res_hash").nil?
        metodo.receiver.instance_variable_set("@cache_res_hash",Hash[])
      end
      if metodo.receiver.instance_variable_get("@cache_res_hash")[metodo.name].nil?
        metodo.receiver.instance_variable_get("@cache_res_hash")[metodo.name] = Hash[]
      end
      metodo.receiver.instance_variable_get("@cache_res_hash")[metodo.name][metodo.receiver.instance_variable_get("@cache_args")] = res
    end)

    @cacheAspecto.add_behaviour(:on_error,lambda do |metodo, e|
      metodo.receiver.instance_variable_get("@cache_res")
    end)

    @a=Foo4.new

  end
  after do
    Object.send :remove_const, :Foo4
    Object.subclasses.clear
  end


  it 'should cachear metodos con 0 parametros sin importar el estado' do
    @a.otro=(0)
    @a.heavy0.should == 0
    @a.otro=(1)
    @a.heavy0.should == 0
  end

  it 'should cachear metodos con 1 parametro sin importar el estado' do
    @a.otro=(3)
    @a.heavy(3).should == 9
    @a.otro=(4)
    @a.heavy(3).should == 9
    @a.heavy(4).should == 16
    @a.otro=(0)
    @a.heavy(4).should == 16
  end

  it 'should cachear metodos con 2 parametros sin importar el estado' do
    @a.otro=(3)
    @a.heavy2(3,3).should == 27
    @a.otro=(4)
    @a.heavy2(3,3).should == 27
    @a.heavy2(4,5).should == 80
    @a.otro=(0)
    @a.heavy2(4,5).should == 80
  end

end