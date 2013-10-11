class Pointcut_Builder

end

class Pointcut
  attr_accessor :clases,:metodos

  def initialize
    @clases=[]
    @metodos=[]
  end

  def and(otroPC)
    @clases.select!{|clase| otroPC.clases.include?(clase) }
    @metodos.select!{|met| otroPC.metodos.map{|met| met.inspect}.include?(met.inspect)}
    self
  end

  def or(otroPC)
    (@clases << otroPC.clases).flatten!.uniq!
    otroPC.metodos.each{|met| @metodos.push(met) if !@metodos.map{|met| met.inspect}.include?(met.inspect)}
    self
  end

  def not
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