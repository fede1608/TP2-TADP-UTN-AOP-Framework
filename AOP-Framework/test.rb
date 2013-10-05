
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

class Foo

end
class Foo2

end

class Bar

end

class Hola

end

class Chau < Hola
end


module AOPFramework

  def self.joint_point (args)
      clases=[]
      metodos=[]
      metodos_tot=[]
      args.each do |decl,val|

         p clases << Object.subclasses.select{|klass| klass.to_s =~ (val)} if decl.to_s.start_with?('clase') && val.is_a?(Regexp)

         p clases << val if decl.to_s.start_with?('clase') && val.is_a?(Array)

         p clases << val.ancestors.select{|ances| ances.is_a?(Class) && ! Object.ancestors.include?(ances)} if decl.to_s.start_with?('hierarchy')

      end

      clases = clases.flatten.uniq

      if clases==[]
        clases= Object.subclasses
      end


      clases.each do |klass|
        metodos_tot << klass.public_methods(false)
      end

      p metodos_tot = metodos_tot.flatten.uniq
      args.each do |decl,val|
        p metodos << metodos_tot.select{|metodo| metodo.to_s =~ val } if decl.to_s.start_with?('metodo') && val.is_a?(Regexp)
        p metodos << val if decl.to_s.start_with?('metodo') && val.is_a?(Array)
      end

      if (args[:accessors])
        clases.each do |klass|
          metodos << klass.attr_readers
          metodos << klass.attr_writers
        end
      end

      p metodos = metodos.flatten.uniq
      Hash[:clases => clases, :metodos => metodos]
  end

end

class Aspect
  attr_accessor :point_cuts
  def initialize
    @point_cuts=[]
  end

end

p Object.subclasses
aspecto= Aspect.new
aspecto.point_cuts=(AOPFramework::joint_point(clase:/Foo/, metodo:/inher/,clase2:/Bar/,clase3:/Bar/,clase4:[Aspect,Foo],hierarchy:Chau,accessors:true))

p aspecto.point_cuts


p Aspect.attr_writers





#@@subclasses.each do |klass|
# p klass.public_methods(false)
#end