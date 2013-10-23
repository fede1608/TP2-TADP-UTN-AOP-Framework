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

    @options.each do |key,value|
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
      @seCumple<<lambda{|metodo| @options[:class_hierarchy].ancestors.include?(metodo.owner) && @seCumple.call(met)}
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

end


module Aspect_examples

  def logging
    require 'logger'
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    logger.formatter = lambda do |severity, datetime, progname, msg|
      "#{datetime} #{severity}: #{msg}\n"
    end
    logger.info "Iniciando Aspecto de loggeo"
    self.add_behaviour(:before, lambda {|met,*args| logger.info "Se ejecuto el metodo: #{met.name.to_s} de la Clase: #{met.owner.name} con los parametros: #{args.to_s}" })
    self.add_behaviour(:after, lambda {|met,res| logger.info "El resultado es: #{res.to_s}" })
  end

  def benchmarking
    require 'logger'
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    logger.formatter = lambda do |severity, datetime, progname, msg|
      "#{datetime} #{severity}: #{msg}\n"
    end
    self.add_behaviour(:before, lambda {|met,*arguments|@start_time = Time.now})
    self.add_behaviour(:after, lambda {|met,res|  logger.info (Time.now - @start_time).to_s + " have elapsed to execute Method: #{met.name.to_s} from Class: #{met.owner.name.to_s}"})
  end

end

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

class Object
  @@subclasses = []

  def self.inherited(subclass)
    @@subclasses << subclass
    @@subclasses.uniq!
    @@subclasses
  end
  def self.subclasses
    @@subclasses
  end
end

class Class
  alias_method :attr_reader_without_tracking, :attr_reader
  def attr_reader(*names)
    attr_readers.concat(names)
    attr_reader_without_tracking(*names)
  end

  def attr_readers
    @attr_readers ||= [ ]
  end

  alias_method :attr_writer_without_tracking, :attr_writer
  def attr_writer(*names)
    attr_writers.concat(names)
    attr_writer_without_tracking(*names)
  end

  def attr_writers
    @attr_writers ||= [ ]
  end
  Class
  alias_method :attr_accessor_without_tracking, :attr_accessor
  def attr_accessor(*names)
    attr_readers.concat(names)
    attr_writers.concat(names.map{|name| (name.to_s + "=" ).to_sym})
    attr_accessor_without_tracking(*names)
  end
end