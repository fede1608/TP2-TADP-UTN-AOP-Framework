class Object
  def self.inherited(subclass)
    puts "New subclass: #{subclass}"
  end
end

class Foo
end

class Bar < Foo
end

class Baz < Bar
end