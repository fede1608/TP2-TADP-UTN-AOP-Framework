
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


module AOPFramework

  def self.joint_point (args)
      clases=[]
    args.each do |decl,val|
      p Object.subclasses
       p clases << Object.subclasses.select{|klass| klass.to_s =~ (val)} if decl.to_s.start_with?('clase')
    end
    clases.flatten!.uniq!
      p "clases"
    p clases
  end

end

class Aspect
  attr_reader :point_cuts
  def initialize
    @point_cuts=[]
  end

end

AOPFramework::joint_point(clase:/Foo/, metodo:/[aeiou]/,clase2:/[123]/)








#@@subclasses.each do |klass|
# p klass.public_methods(false)
#end