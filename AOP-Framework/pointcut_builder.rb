class Pointcut_Builder
  attr_reader :options
  def initialize
    @seCumple=[lambda{|metodo| !metodo.name.to_s.start_with?('aopF_')}]
    @filtro_de_clases=[proc{true}]
    @filtro_de_metodos=[proc{true}]
    @classes_base=Object.subclasses
  end

  def class_array (val)
    @classes_base=val
    agregar_condicion lambda{|metodo| @classes_base.include?(metodo.owner)}
    self
  end

  def class_hierarchy (clase)
    @classes_base = Object.subclasses.select{|c| clase.ancestors.include?(c)}
    agregar_condicion lambda{|metodo| clase.ancestors.include?(metodo.owner)}
    self
  end

  def class_childs(clase)
    @classes_base = Object.subclasses.select{|c| c.superclass == clase}
    agregar_condicion lambda{|metodo| metodo.owner.superclass == clase }
    self
  end

  def agregar_al_filtro_de_clases(condicion)
    @filtro_de_clases << condicion
    agregar_condicion condicion
  end
  def class_block(a_proc)
    agregar_al_filtro_de_clases lambda { |clase| a_proc.call(clase) }
    self
  end

  def class_regex(regex)
    agregar_al_filtro_de_clases lambda { |clase| clase.name.to_s =~ regex }
    self
  end

  def class_start_with(str)
    agregar_al_filtro_de_clases lambda{|clase| clase.name.to_s.start_with?(str)}
    self
  end

  def agregar_al_filtro_de_metodos(condicion)
    @filtro_de_metodos << condicion
    agregar_condicion condicion
  end

  def method_array(array)
    agregar_al_filtro_de_metodos(lambda{|metodo| (array.include?(metodo.name) || array.map{|metodo| metodo.to_s}.include?(metodo.name.to_s)) })
    self
  end

  def method_accessor(bool)
    agregar_al_filtro_de_metodos lambda{|metodo| (metodo.owner.attr_readers.include?(metodo.name) || metodo.owner.attr_writers.include?(metodo.name) )} if bool
    agregar_al_filtro_de_metodos lambda{|metodo| !(metodo.owner.attr_readers.include?(metodo.name) || metodo.owner.attr_writers.include?(metodo.name) )} unless bool
    self
  end

  def method_parameter_name(name)
    agregar_al_filtro_de_metodos lambda{|metodo| metodo.parameters.map(&:last).map(&:to_s).any?{|p| p==name || p.to_sym ==name} }
    self
  end

  def method_parameters_type(type)
    case type
      when :opt,:req
        agregar_al_filtro_de_metodos lambda{|metodo| metodo.parameters.map(&:first).any?{|p| p.to_s==type.to_s} }
      when :req_all
        agregar_al_filtro_de_metodos lambda{|metodo| metodo.parameters.map(&:first).all?{|p| p.to_s== :req.to_s} }
      when :opt_all
        agregar_al_filtro_de_metodos lambda{|metodo| metodo.parameters.map(&:first).all?{|p| p.to_s== :opt.to_s} }
    end
    self
  end

  def method_block(a_proc)
    agregar_al_filtro_de_metodos lambda{|metodo| a_proc.call(metodo) }
    self
  end

  def method_regex(regex)
    agregar_al_filtro_de_metodos lambda{|metodo| metodo.name.to_s =~ regex}
    self
  end

  def method_start_with(str)
    agregar_al_filtro_de_metodos  lambda{|metodo| metodo.name.to_s.start_with?(str) }
    self
  end

  def method_arity(arity)
    agregar_al_filtro_de_metodos  lambda{|metodo| metodo.arity==arity }
    self
  end


  def crear_pointcut
    @p=Pointcut.new
  end

  def crear_clases_base
    @p.clases=@classes_base
  end

  def filtrar_clases
    @p.clases.select!{|clase| @filtro_de_clases.all?{|cond| cond.call(clase)}}
  end

  def crear_metodos_base
    @p.clases.each do |klass|
      @p.metodos << klass.instance_methods(false).select{|m| !m.to_s.start_with?('aopF_')}.map{|met| klass.instance_method(met)}.select{|m| !m.name.to_s.start_with?('aopF_')}
    end
    @p.metodos.flatten!
  end

  def devolver_pointcut
    @p
  end

  def agregar_lambda_condiciones
    @p.seCumple=lambda{|metodo| @seCumple.all?{|condicion| condicion.call(metodo)}}
  end

  def agregar_builder
    @p.builder=(self.clone)
  end

  def agregar_condicion(cond)
    @seCumple<<cond
  end

  def seleccionar_metodos_que_cumplan_con!(&bloque)
    @p.metodos.select!(&bloque)
  end


  def filtrar_metodos
    @p.metodos.select!{|metodo| @filtro_de_metodos.all?{|cond| cond.call(metodo)}}
  end

  def build
    crear_pointcut()
    crear_clases_base()
    filtrar_clases()
    crear_metodos_base()
    filtrar_metodos()
    agregar_builder()
    agregar_lambda_condiciones()
    devolver_pointcut()
  end


end
