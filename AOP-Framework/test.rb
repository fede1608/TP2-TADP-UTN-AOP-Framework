
class Object
  @@subclasses = []

  def self.inherited(subclass)
    @@subclasses << subclass
  end
  def self.subclasses
    @@subclasses
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
    args.each do |decl,val|

       p clases << Object.subclasses.select{|klass| klass.to_s =~ (val)} if decl.to_s.start_with?('clase') && val.is_a?(Regexp)

       p clases << val if decl.to_s.start_with?('clase') && val.is_a?(Array)

       p clases << val.ancestors.select{|ances| ances.is_a?(Class) && ! Object.ancestors.include?(ances)} if decl.to_s.start_with?('hierarchy')
    end
    clases.flatten.uniq
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
aspecto.point_cuts=(AOPFramework::joint_point(clase:/Foo/, metodo:/[aeiou]/,clase2:/Bar/,clase3:/Bar/,clase4:[Aspect,Foo],hierarchy:Chau))

p aspecto.point_cuts








#@@subclasses.each do |klass|
# p klass.public_methods(false)
#end