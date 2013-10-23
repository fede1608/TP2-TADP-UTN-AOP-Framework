class Pointcut_Builder
  attr_reader :options
  def initialize
    @seCumple=[lambda{|metodo| !metodo.name.to_s.start_with?('aopF_')}]
    @options = Hash.new

    @options[:class_array] = nil
    @options[:class_hierarchy] = nil
    @options[:class_childs] = nil

    @options[:class_block] = nil
    @options[:class_regex] = nil
    @options[:class_start_with] = nil

    @options[:method_array] = nil
    @options[:method_accessor] = nil
    @options[:method_parameter_name] = nil
    @options[:method_parameters_type] = nil
    @options[:method_block] = nil
    @options[:method_regex] = nil
    @options[:method_start_with] = nil
    @options[:method_arity] = nil

    @options.each do |key,value| #crea los setters automaticamente segun las optiones inicializadas, se vuelven a definir mas adelante para que aparezcan en el IDE al programar
      self.class.class_eval do
        define_method key do |val|
          @options[key]=val
          self
        end
      end
    end

  end


  def crear_pointcut
    @p=Pointcut.new
  end

  def crear_clases_base
    baseClass=Object.subclasses

    if !@options[:class_array].nil?
      @p.clases = @options[:class_array]
      @seCumple<<lambda{|metodo| @options[:class_array].include?(metodo.owner)}
    elsif !@options[:class_hierarchy].nil?
      @p.clases = baseClass.select{|c| @options[:class_hierarchy].ancestors.include?(c)}
      @seCumple<<lambda{|metodo| @options[:class_hierarchy].ancestors.include?(metodo.owner)}
    elsif !@options[:class_childs].nil?
      @p.clases = baseClass.select{|c| c.superclass == @options[:class_childs]}
      @seCumple<<lambda{|metodo| metodo.owner.superclass == @options[:class_childs] }
    else
      @p.clases= baseClass.clone
    end
  end

  def filtrar_clases
    if !@options[:class_block].nil?
      @p.clases.select!(&@options[:class_block])
      @seCumple<<lambda{|metodo| @options[:class_block].call(metodo.owner) }
    end
    if !@options[:class_regex].nil?
      @p.clases.select!{|a| a.name.to_s =~ @options[:class_regex]}
      @seCumple<<lambda{|metodo| metodo.owner.name.to_s =~ @options[:class_regex] }
    end
    if !@options[:class_start_with].nil?
      @p.clases.select!{|clase| clase.name.to_s.start_with?(@options[:class_start_with])}
      @seCumple<<lambda{|metodo| metodo.owner.name.to_s.start_with?(@options[:class_start_with]) }
    end
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
    @options.select{|key,value| !value.nil? && key.to_s.start_with?('method')}.each do |key,value|
      case key
        when :method_array
          seleccionar_metodos_que_cumplan_con! {|metodo| @options[:method_array].include?(metodo.name) || @options[:method_array].map{|metodo| metodo.to_s}.include?(metodo.name.to_s) }
          agregar_condicion lambda{|metodo| (@options[:method_array].include?(metodo.name) || @options[:method_array].map{|metodo| metodo.to_s}.include?(metodo.name.to_s)) }
        when :method_accessor
          if @options[:method_accessor]
            seleccionar_metodos_que_cumplan_con! {|m| m.owner.attr_readers.include?(m.name) || m.owner.attr_writers.include?(m.name) }
            agregar_condicion lambda{|metodo| (metodo.owner.attr_readers.include?(metodo.name) || metodo.owner.attr_writers.include?(metodo.name) )}
          else
            seleccionar_metodos_que_cumplan_con! {|m| !m.owner.attr_readers.include?(m.name) && !m.owner.attr_writers.include?(m.name) }
            agregar_condicion lambda{|metodo| !(metodo.owner.attr_readers.include?(metodo.name) || metodo.owner.attr_writers.include?(metodo.name) )}
          end
        when :method_parameter_name
          seleccionar_metodos_que_cumplan_con! {|m| m.parameters.map(&:last).map(&:to_s).any?{|p| p==@options[:method_parameter_name] || p.to_sym ==@options[:method_parameter_name]}}
          agregar_condicion lambda{|metodo| metodo.parameters.map(&:last).map(&:to_s).any?{|p| p==@options[:method_parameter_name] || p.to_sym ==@options[:method_parameter_name]} }
        when :method_parameters_type
          case @options[:method_parameters_type]
            when :opt,:req
              seleccionar_metodos_que_cumplan_con! {|m| m.parameters.map(&:first).any?{|p| p.to_s==@options[:method_parameters_type].to_s}}
              agregar_condicion lambda{|metodo| metodo.parameters.map(&:first).any?{|p| p.to_s==@options[:method_parameters_type].to_s} }
            when :req_all
              seleccionar_metodos_que_cumplan_con! {|m| m.parameters.map(&:first).all?{|p| p.to_s== :req.to_s}}
              agregar_condicion lambda{|metodo| metodo.parameters.map(&:first).all?{|p| p.to_s== :req.to_s} }
            when :opt_all
              seleccionar_metodos_que_cumplan_con! {|m| m.parameters.map(&:first).all?{|p| p.to_s== :opt.to_s}}
              agregar_condicion lambda{|metodo| metodo.parameters.map(&:first).all?{|p| p.to_s== :opt.to_s} }
          end
        when :method_block
          seleccionar_metodos_que_cumplan_con!(&@options[:method_block])
          agregar_condicion lambda{|metodo| @options[:method_block].call(metodo) }
        when :method_regex
          seleccionar_metodos_que_cumplan_con! {|a| a.name.to_s =~ @options[:method_regex]}
          agregar_condicion lambda{|metodo| metodo.name.to_s =~ @options[:method_regex] }
        when :method_start_with
          seleccionar_metodos_que_cumplan_con! {|m| m.name.to_s.start_with?(@options[:method_start_with])}
          agregar_condicion lambda{|metodo| metodo.name.to_s.start_with?(@options[:method_start_with]) }
        when :method_arity
          seleccionar_metodos_que_cumplan_con! {|metodo| metodo.arity==@options[:method_arity] }
          agregar_condicion lambda{|metodo| metodo.arity==@options[:method_arity] }
      end
    end
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

  def class_array (val)
    @options[__method__]=val
    self
  end
  alias_method :class_hierarchy, :class_array
  alias_method :class_childs, :class_array
  alias_method :class_block, :class_array
  alias_method :class_regex, :class_array
  alias_method :class_start_with, :class_array
  alias_method :method_array, :class_array
  alias_method :method_accessor, :class_array
  alias_method :method_parameter_name, :class_array
  alias_method :method_parameters_type, :class_array
  alias_method :method_block, :class_array
  alias_method :method_regex, :class_array
  alias_method :method_start_with, :class_array
  alias_method :method_arity, :class_array
end
