class Aspect
  attr_accessor :builder, :pointcut ,:dyn_methods

  include Aspect_examples

  def initialize
    @builder = Pointcut_Builder.new
    @pointcut = nil
    @dyn_methods= true
    @behaviours=[]
  end



  def add_behaviour(where,behaviour)
    @pointcut.metodos.each do |metodo|
      add_behaviour_method(where,behaviour,metodo)
    end

    if @dyn_methods
      add_dyn_method_handler
      @behaviours.push(Hash[where=>behaviour])
    end
  end

  def apply_behaviours(metodo)
    if !@pointcut.metodos.map{|m| m.inspect}.include?(metodo.inspect)
      @pointcut.metodos.push(metodo)
      @behaviours.each do |b|
        b.each do |where,behaviour|
          add_behaviour_method(where,behaviour,metodo)
        end
      end
    end
  end

  private

  def add_dyn_method_handler
    aspect=self.clone #TODO:revisar
    @pointcut.clases.each do |clase|
      clase.class_eval do
        define_singleton_method :method_added do |method_name|
          if aspect.pointcut.seCumple?(clase.instance_method(method_name))
            aspect.apply_behaviours(clase.instance_method(method_name))
          end
        end
      end
    end
  end

  def add_behaviour_method(where,behaviour,metodo)
    old_sym = ('aopF_' + (0...8).map { (65 + rand(26)).chr }.join + "_#{metodo.name.to_s}" ).to_sym
    new_sym=  metodo.name
    puts "Se modifico el metodo: #{new_sym.to_s} de la Clase: #{metodo.owner.to_s} "
    #puts "Exmetodo: #{old_sym.to_s}"
    #metodo.owner.class_eval("def #{metodo.name.to_s}(*args); puts 'Se Sobreescribio #{metodo.name.to_s}';end #self.orig_#{metodo.name.to_s}(*args);  end")
    metodo.owner.class_eval("alias_method :#{old_sym.to_s} , :#{new_sym.to_s}")
    case where
      when :before
        metodo.owner.class_eval do
          define_method new_sym do |*arguments|
            behaviour.call(self.method(metodo.name),*arguments)
            self.send(old_sym,*arguments)
          end
        end
      when :after
        metodo.owner.class_eval do
          define_method new_sym do |*arguments|
            res = self.send(old_sym,*arguments)
            behaviour.call(self.method(metodo.name),res)
            res
          end
        end
      when :instead
        metodo.owner.class_eval do
          define_method new_sym do |*arguments|
            behaviour.call(self.method(metodo.name),self.method(old_sym),*arguments)
          end
        end
      when :on_error
        metodo.owner.class_eval do
          define_method new_sym do |*arguments|
            begin
              self.send(old_sym,*arguments)
            rescue Exception => e
              behaviour.call(self.method(metodo.name), e)
            end
          end
        end
    end
  end

end
