
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




class AOPFramework
  attr_accessor :metodos,:clases
  def initialize
    @clases=[]
    @metodos_obj=[]
    @metodos=[]
  end

  def point_cut(bloque_clase,bloque_metodo)
    bloque_iterator = lambda do |klass|
      @metodos_obj << klass.instance_methods(false).map{|met| klass.new.method(met)}
    end
    point_cut_core(bloque_clase,bloque_metodo,bloque_iterator)
  end

  def point_cut_bloque_clase(bloque_clase)
   bloque_metodo= lambda {|a| true}
   point_cut(bloque_clase,bloque_metodo)
  end

  def point_cut_bloque_metodo(bloque_metodo)
    bloque_clase= lambda {|a| true}
    point_cut(bloque_clase,bloque_metodo)
  end

  def point_cut_regexp(reg_clases,reg_metodos)
    lambda_clase=lambda {|a| a.name.to_s =~ reg_clases}
    lambda_metodo=lambda {|a| a.name.to_s =~ reg_metodos}
    point_cut(lambda_clase,lambda_metodo)
  end

  def point_cut_regexp_clase(reg_clases)
    reg_metodos=/./
    point_cut_regexp(reg_clases,reg_metodos)
  end

  def point_cut_regexp_metodos(reg_metodos)
    reg_clases=/./
    point_cut_regexp(reg_clases,reg_metodos)
  end

  def point_cut_method_start_with(string_metodo)
    bloque_metodo=lambda{|metodo| metodo.name.to_s.start_with?(string_metodo)}
    point_cut_bloque_metodo(bloque_metodo)
  end

  def point_cut_accessors(bloque_clase)
    bloque_metodo = lambda{|a| true}
    bloque_iterator = lambda { |klass|
        @metodos_obj << klass.attr_readers.map{|met| klass.new.method(met)}
        @metodos_obj << klass.attr_writers.map{|met| klass.new.method(met)}
    }
    point_cut_core(bloque_clase,bloque_metodo,bloque_iterator)
  end

  def point_cut_hierarchy(clase)
    bloque_clase=lambda{|klass| clase.ancestors.include?(klass) }
    point_cut_bloque_clase(bloque_clase)
  end

  def point_cut_array_clase(array_clase)
    bloque_clase=lambda{|klass| array_clase.include?(klass) }
    point_cut_bloque_clase(bloque_clase)
  end

  def point_cut_array_metodos(array_metodos)
    bloque_metodo=lambda{|metodo| array_metodos.include?(metodo.name) || array_metodos.map{|metodo| metodo.to_s}.include?(metodo.name.to_s) }
    point_cut_bloque_metodo(bloque_metodo)
  end

  private

  def point_cut_core(bloque_clase,bloque_metodo,bloque_iterador)
    initialize
    @clases=Object.subclasses.select(&bloque_clase)
    @clases.each(&bloque_iterador)
    @metodos_obj.flatten!
    @metodos=@metodos_obj.select(&bloque_metodo)
    Hash[:clases => @clases, :metodos => @metodos]
  end

end
