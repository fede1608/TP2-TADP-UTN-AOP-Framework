require_relative '../AOP-Framework/AOPFramework'

class Foo3
  attr_accessor :algo,:otro,:otromas

  def heavy(number)
    if number==-1
      raise "error"
    end
    number*3
  end
  def heavy2(number,number2)
    number*number2
  end
end
class Bar3 < Foo3
  attr_accessor :algo3,:otro3
end


transactionAspectAccessors=Aspect.new
transactionAspectAccessors.dyn_methods =false
transactionAspectAccessors.pointcut=(transactionAspectAccessors.builder.method_accessor(true).build)
transactionAspectAccessors.add_behaviour(:instead,lambda do |metodo,orig_method,*args|
  if @undo_self.nil?
     @undo_self= metodo.receiver.clone
  end
  @undo_self.send(orig_method.name,*args)
end)

transaction_Aspect_Commit_Rollback=Aspect.new
transaction_Aspect_Commit_Rollback.dyn_methods =false
transaction_Aspect_Commit_Rollback.pointcut=(transactionAspectAccessors.builder.method_accessor(true).build.not)
transaction_Aspect_Commit_Rollback.add_behaviour(:after, lambda do |metodo, res|
  if @undo_self.nil?
    @undo_self= metodo.receiver.clone
  end
  @undo_self.instance_variables.each do |var|
    metodo.receiver.instance_variable_set(var,@undo_self.instance_variable_get(var))
  end
end)
transaction_Aspect_Commit_Rollback.add_behaviour(:on_error,lambda do |metodo,e|
  @undo_self= metodo.receiver.clone
end)

foo=Foo3.new
p foo
foo.otro=(8)
p foo
foo.heavy(4)
p foo
p foo.otro
foo.otro=(19)
p foo.otro
foo.heavy(-1)
p foo.otro


