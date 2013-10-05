
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

    args.each do |decl,val|
      p Object.subclasses
       p Object.subclasses.select{|klass| klass.to_s =~ (val)} if decl.to_s.start_with?("clase")
    end
  end

end


AOPFramework::joint_point(clase:/Foo/, metodo:/[aeiou]/,clase2:/[123]/)








#@@subclasses.each do |klass|
# p klass.public_methods(false)
#end