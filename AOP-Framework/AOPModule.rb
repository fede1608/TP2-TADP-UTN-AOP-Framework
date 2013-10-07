
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
  def initialize
    @clases=[]
    @metodos=[]
  end

  def point_cut(bloqueClases,bloqueMetodos)
    metodos_tot=[]
    metodos_obj=[]

    @clases=Object.subclasses.select(&bloqueClases)

    @clases.each do |klass|

      metodos_obj << klass.instance_methods(false).map{|met| klass.method(met)}
      metodos_tot << klass.instance_methods(false)

    end

    metodos_obj.flatten!.uniq!
    @metodos= metodos_obj.select(&bloqueMetodos)

    Hash[:clases => @clases, :metodos => @metodos]
  end

  def point_cut_regexp(reg_clases,reg_metodos)
  lambda_clase=lambda {|a| a.name =~ reg_clases}
  lambda_metodo=lambda {|a| a.name =~ reg_metodos}
    point_cut(lambda_clase,lambda_metodo)
  end

  def point_cut_regexp_clase(reg_clases)

  end

  def point_cut_regexp_metodos(reg_metodos)

  end

end
