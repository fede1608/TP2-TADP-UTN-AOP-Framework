class Pointcut_Builder
  attr_reader :options
  def initialize
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
    @options[:method_parameters_type] = :all
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
    elsif !@options[:class_hierarchy].nil?
      p.clases = baseClass.select{|c| @options[:class_hierarchy].ancestors.include?(c)}
    elsif !@options[:class_childs].nil?
      p.clases = baseClass.select{|c| c.superclass == @options[:class_childs]}
    else
      p.clases= baseClass.clone
    end

    if !@options[:class_block].nil?
      p.clases.select!(&@options[:class_block])
    end
    if !@options[:class_regex].nil?
      p.clases.select!{|a| a.name.to_s =~ @options[:class_regex]}
    end
    if !@options[:class_start_with].nil?
      p.clases.select!{|clase| clase.name.to_s.start_with?(@options[:class_start_with])}
    end
    p.clases.each do |klass|
      p.metodos << klass.instance_methods(false).map{|met| klass.instance_method(met)}.select{|m| !m.name.to_s.start_with?('aopF_')}
    end
    p.metodos.flatten!

    if !@options[:method_array].nil?
      p.metodos.select!{|metodo| @options[:method_array].include?(metodo.name) || @options[:method_array].map{|metodo| metodo.to_s}.include?(metodo.name.to_s) }
    end
    if !@options[:method_accessor].nil?
      p.metodos.select!{|m| m.owner.attr_readers.include?(m.name) || m.owner.attr_writers.include?(m.name) } if @options[:method_accessor]
      p.metodos.select!{|m| !m.owner.attr_readers.include?(m.name) && !m.owner.attr_writers.include?(m.name) } unless @options[:method_accessor]
    end
    if !@options[:method_parameter_name].nil?

    end
    if !@options[:method_parameters_type]==:all
      case @options[:method_parameters_type]
        when :opt
        when :req
      end
    end
    if !@options[:method_block].nil?
      p.metodos.select!(&@options[:method_block])
    end
    if !@options[:method_regex].nil?
      p.metodos.select!{|a| a.name.to_s =~ @options[:method_regex]}
    end
    if !@options[:method_start_with].nil?
      p.metodos.select!{|m| m.name.to_s.start_with?(@options[:method_start_with])}
    end
    if !@options[:method_arity].nil?
      p.metodos.select!{|metodo| metodo.arity==@options[:method_arity] }
    end
    p.builder=(self.clone)
    p
  end

  def seCumple?(metodo)
    return false if metodo.name.to_s.start_with?('aopF_')

    if !@options[:class_array].nil?
      return false unless @options[:class_array].include?(metodo.owner)
    elsif !@options[:class_hierarchy].nil?
      return false unless @options[:class_hierarchy].ancestors.include?(metodo.owner)
    elsif !@options[:class_childs].nil?
      return false unless metodo.owner.superclass == @options[:class_childs]
    end

    if !@options[:class_block].nil?
      return false unless @options[:class_block].call(metodo.owner)
    end
    if !@options[:class_regex].nil?
      return false unless metodo.owner.name.to_s =~ @options[:class_regex]
    end
    if !@options[:class_start_with].nil?
      return false unless metodo.owner.name.to_s.start_with?(@options[:class_start_with])
    end

    if !@options[:method_array].nil?
      return false unless (@options[:method_array].include?(metodo.name) || @options[:method_array].map{|metodo| metodo.to_s}.include?(metodo.name.to_s))
    end
    if !@options[:method_accessor].nil?
      if @options[:method_accessor]
      return false unless (metodo.owner.attr_readers.include?(metodo.name) || metodo.owner.attr_writers.include?(metodo.name) )
      else
      return false if (metodo.owner.attr_readers.include?(metodo.name) || metodo.owner.attr_writers.include?(metodo.name) )
      end
    end
    if !@options[:method_parameter_name].nil?
       #should be implemented
    end
    if !@options[:method_parameters_type]==:all
      case @options[:method_parameters_type]
        when :opt
          #should be implemented
        when :req
          #should be implemented
      end
    end
    if !@options[:method_block].nil?
      return false unless @options[:method_block].call(metodo)
    end
    if !@options[:method_regex].nil?
      return false unless metodo.name.to_s =~ @options[:method_regex]
    end
    if !@options[:method_start_with].nil?
      return false unless metodo.name.to_s.start_with?(@options[:method_start_with])
    end
    if !@options[:method_arity].nil?
       return false unless metodo.arity==@options[:method_arity]
    end
    return true
  end

  def class_array (val)
    @options[:class_array]=val
    self
  end
  def class_hierarchy (val)
    @options[:class_hierarchy]=val
    self
  end
  def class_childs (val)
    @options[:class_childs]=val
    self
  end
  def class_block (val)
    @options[:class_block]=val
    self
  end
  def class_regex (val)
    @options[:class_regex]=val
    self
  end
  def class_start_with (val)
    @options[:class_start_with]=val
    self
  end
  def method_array (val)
    @options[:method_array]=val
    self
  end
  def method_accessor (val)
    @options[:method_accessor]=val
    self
  end
  def method_parameter_name (val)
    @options[:method_parameter_name]=val
    self
  end
  def method_parameters_type (val)
    @options[:method_parameters_type]=val
    self
  end
  def method_block (val)
    @options[:method_block]=val
    self
  end
  def method_regex (val)
    @options[:method_regex]=val
    self
  end
  def method_start_with (val)
    @options[:method_start_with]=val
    self
  end
  def method_arity (val)
    @options[:method_arity]=val
    self
  end



end

class Pointcut
  attr_accessor :clases,:metodos,:builder

  def initialize
    @clases=[]
    @metodos=[]
    @builder=nil
  end

  def seCumple?(metodo)
    @builder.seCumple?(metodo)
  end

  def and(otroPC)
    pc_and=Pointcut_and.new
    pc_and.clases=(@clases.select{|clase| otroPC.clases.include?(clase) })
    pc_and.metodos=(@metodos.select{|met| otroPC.metodos.map{|met| met.inspect}.include?(met.inspect)})
    pc_and.pointcuts_and1=(self)
    pc_and.pointcuts_and2=(otroPC)
    pc_and
  end

  def or(otroPC)
    pc_or=Pointcut_or.new
    pc_or.clases=(@clases)
    (pc_or.clases << otroPC.clases).flatten!.uniq!
    pc_or.metodos=(@metodos)
    otroPC.metodos.each{|met| pc_or.metodos.push(met) if !pc_or.metodos.map{|met| met.inspect}.include?(met.inspect) && !met.name.to_s.start_with?('aopF_')}
    pc_or.pointcuts_or1=(self)
    pc_or.pointcuts_or2=(otroPC)
    pc_or
  end

  def not
    pc_not=Pointcut_not.new

    metodos_obj = []
    @clases.each  do |klass|
      metodos_obj << klass.instance_methods(false).map{|met| klass.instance_method(met)}.select{|m| !m.name.to_s.start_with?('aopF_')}
    end
    pc_not.metodos=(metodos_obj.flatten.select{|met| !@metodos.map{|met| met.inspect}.include?(met.inspect)})

    clases_aux = Object.subclasses.select{|clase| !@clases.include?(clase)}
    metodos_cls = []
    clases_aux.each  do |klass|
          metodos_cls << klass.instance_methods(false).map{|met| klass.instance_method(met)}.select{|m| !m.name.to_s.start_with?('aopF_')}
    end
    (pc_not.metodos << metodos_cls.flatten.compact).flatten!

    pc_not.metodos.each do |metodo|
      pc_not.clases.push(metodo.owner)
    end
    pc_not.clases.uniq!
    pc_not.pointcut_not=(self)
    pc_not
  end

end

class Pointcut_and < Pointcut
  attr_accessor :pointcuts_and1,:pointcuts_and2

  def initialize
    super
    @pointcuts_and1=nil
    @pointcuts_and2=nil
  end

  def seCumple?(metodo)
    @pointcuts_and1.seCumple?(metodo) && @pointcuts_and2.seCumple?(metodo)
  end

end

class Pointcut_or < Pointcut
  attr_accessor :pointcuts_or1,:pointcuts_or2

  def initialize
    super
    @pointcuts_or1=nil
    @pointcuts_or2=nil
  end

  def seCumple?(metodo)
    @pointcuts_or1.seCumple?(metodo) || @pointcuts_or2.seCumple?(metodo)
  end
end

class Pointcut_not < Pointcut
  attr_accessor :pointcut_not

  def initialize
    super
    @pointcut_not=nil
  end

  def seCumple?(metodo)
    !@pointcut_not.seCumple?(metodo)
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