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

  def build
    baseClass=Object.subclasses
    p=Pointcut.new
    if !@options[:class_array].nil?
      p.clases = @options[:class_array]
      @seCumple<<lambda{|metodo| @options[:class_array].include?(metodo.owner)}
    elsif !@options[:class_hierarchy].nil?
      p.clases = baseClass.select{|c| @options[:class_hierarchy].ancestors.include?(c)}
      @seCumple<<lambda{|metodo| @options[:class_hierarchy].ancestors.include?(metodo.owner)}
    elsif !@options[:class_childs].nil?
      p.clases = baseClass.select{|c| c.superclass == @options[:class_childs]}
      @seCumple<<lambda{|metodo| metodo.owner.superclass == @options[:class_childs] }
    else
      p.clases= baseClass.clone
    end

    if !@options[:class_block].nil?
      p.clases.select!(&@options[:class_block])
      @seCumple<<lambda{|metodo| @options[:class_block].call(metodo.owner) }
    end
    if !@options[:class_regex].nil?
      p.clases.select!{|a| a.name.to_s =~ @options[:class_regex]}
      @seCumple<<lambda{|metodo| metodo.owner.name.to_s =~ @options[:class_regex] }
    end
    if !@options[:class_start_with].nil?
      p.clases.select!{|clase| clase.name.to_s.start_with?(@options[:class_start_with])}
      @seCumple<<lambda{|metodo| metodo.owner.name.to_s.start_with?(@options[:class_start_with]) }
    end
    p.clases.each do |klass|
      p.metodos << klass.instance_methods(false).select{|m| !m.to_s.start_with?('aopF_')}.map{|met| klass.instance_method(met)}.select{|m| !m.name.to_s.start_with?('aopF_')}
    end
    p.metodos.flatten!
    if !@options[:method_array].nil?
      p.metodos.select!{|metodo| @options[:method_array].include?(metodo.name) || @options[:method_array].map{|metodo| metodo.to_s}.include?(metodo.name.to_s) }
      @seCumple<<lambda{|metodo| (@options[:method_array].include?(metodo.name) || @options[:method_array].map{|metodo| metodo.to_s}.include?(metodo.name.to_s)) }
    end
    if !@options[:method_accessor].nil?

      if @options[:method_accessor]
        p.metodos.select!{|m| m.owner.attr_readers.include?(m.name) || m.owner.attr_writers.include?(m.name) } if @options[:method_accessor]
        @seCumple<<lambda{|metodo| (metodo.owner.attr_readers.include?(metodo.name) || metodo.owner.attr_writers.include?(metodo.name) )}
      else
        p.metodos.select!{|m| !m.owner.attr_readers.include?(m.name) && !m.owner.attr_writers.include?(m.name) } unless @options[:method_accessor]
        @seCumple<<lambda{|metodo| !(metodo.owner.attr_readers.include?(metodo.name) || metodo.owner.attr_writers.include?(metodo.name) )}
      end
    end
    if !@options[:method_parameter_name].nil?
      p.metodos.select!{|m| m.parameters.map(&:last).map(&:to_s).any?{|p| p==@options[:method_parameter_name] || p.to_sym ==@options[:method_parameter_name]}}
      @seCumple<<lambda{|metodo| metodo.parameters.map(&:last).map(&:to_s).any?{|p| p==@options[:method_parameter_name] || p.to_sym ==@options[:method_parameter_name]} }
    end
    if !@options[:method_parameters_type].nil?
      case @options[:method_parameters_type]
        when :opt,:req
          p.metodos.select!{|m| m.parameters.map(&:first).any?{|p| p.to_s==@options[:method_parameters_type].to_s}}
          @seCumple<<lambda{|metodo| metodo.parameters.map(&:first).any?{|p| p.to_s==@options[:method_parameters_type].to_s} }
        #  when :req
        #    p.metodos.select!{|m| m.parameters.map(&:first).any?{|p| p==@options[:method_parameters_type]}&& m.arity!=0}
        when :req_all
          p.metodos.select!{|m| m.parameters.map(&:first).all?{|p| p.to_s== :req.to_s}}
          @seCumple<<lambda{|metodo| metodo.parameters.map(&:first).all?{|p| p.to_s== :req.to_s} }
        when :opt_all
          p.metodos.select!{|m| m.parameters.map(&:first).all?{|p| p.to_s== :opt.to_s}}
          @seCumple<<lambda{|metodo| metodo.parameters.map(&:first).all?{|p| p.to_s== :opt.to_s} }
      end

    end
    if !@options[:method_block].nil?
      p.metodos.select!(&@options[:method_block])
      @seCumple<<lambda{|metodo| @options[:method_block].call(metodo) }
    end
    if !@options[:method_regex].nil?
      p.metodos.select!{|a| a.name.to_s =~ @options[:method_regex]}
      @seCumple<<lambda{|metodo| metodo.name.to_s =~ @options[:method_regex] }
    end
    if !@options[:method_start_with].nil?
      p.metodos.select!{|m| m.name.to_s.start_with?(@options[:method_start_with])}
      @seCumple<<lambda{|metodo| metodo.name.to_s.start_with?(@options[:method_start_with]) }
    end
    if !@options[:method_arity].nil?
      p.metodos.select!{|metodo| metodo.arity==@options[:method_arity] }
      @seCumple<<lambda{|metodo| metodo.arity==@options[:method_arity] }
    end
    p.builder=(self.clone)
    p.seCumple=lambda{|metodo| @seCumple.all?{|condicion| condicion.call(metodo)}}
    p
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