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
    @options[:method_accessor] = false
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
      p.metodos << klass.instance_methods(false).map{|met| klass.instance_method(met)}
    end
    p.metodos.flatten!

    if !@options[:method_array].nil?
      p.metodos.select!{|metodo| @options[:method_array].include?(metodo.name) || @options[:method_array].map{|metodo| metodo.to_s}.include?(metodo.name.to_s) }
    end
    if @options[:method_accessor]
      p.metodos.select!{|m| m.owner.attr_readers.include?(m.name) || m.owner.attr_writers.include?(m.name) }
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

    p
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
  attr_accessor :clases,:metodos

  def initialize
    @clases=[]
    @metodos=[]
  end

  def and!(otroPC)
    @clases.select!{|clase| otroPC.clases.include?(clase) }
    @metodos.select!{|met| otroPC.metodos.map{|met| met.inspect}.include?(met.inspect)}
    self
  end

  def or!(otroPC)
    (@clases << otroPC.clases).flatten!.uniq!
    otroPC.metodos.each{|met| @metodos.push(met) if !@metodos.map{|met| met.inspect}.include?(met.inspect)}
    self
  end

  def not!(tipo)
    case tipo
      when :metodo
        metodos_obj = []
        @clases.each  do |klass|
          metodos_obj << klass.instance_methods(false).map{|met| klass.instance_method(met)}
        end
        @metodos = metodos_obj.flatten.select{|met| !@metodos.map{|met| met.inspect}.include?(met.inspect)}
      when :clase
        @clases = Object.subclasses.select{|clase| !@clases.include?(clase)}
        @metodos = []
        @clases.each  do |klass|
          @metodos << klass.instance_methods(false).map{|met| klass.instance_method(met)}
        end
        @metodos.flatten!
    end
    self
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
  end

end

class Aspect
  attr_accessor :builder, :pointcut

  include Aspect_examples

  def initialize
  @builder = Pointcut_Builder.new
  @pointcut = nil
  end

  def add_behaviour(where,behaviour)
    @pointcut.metodos.each do |metodo|
      old_sym = ((0...8).map { (65 + rand(26)).chr }.join + "__#{metodo.name.to_s}" ).to_sym
      new_sym=  metodo.name
      puts "Se modifico el metodo: #{new_sym.to_s} de la Clase: #{metodo.owner.to_s}"
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
              behaviour.call(self.method(metodo.name),res)
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

  alias_method :attr_accessor_without_tracking, :attr_accessor
  def attr_accessor(*names)
    attr_readers.concat(names)
    attr_writers.concat(names.map{|name| (name.to_s + "=" ).to_sym})
    attr_accessor_without_tracking(*names)
  end
end