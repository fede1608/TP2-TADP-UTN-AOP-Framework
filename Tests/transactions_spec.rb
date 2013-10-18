require 'rspec'

describe 'Transaction Aspect' do
  before :each do
    require_relative '../AOP-Framework/AOPFramework'
    class Foo6
      attr_accessor :algo,:otro,:otromas
      def initialize
      end
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
    class Bar6 < Foo6
      attr_accessor :algo3,:otro3
    end

    @transactionAspectAccessors=Aspect.new
    @transactionAspectAccessors.pointcut=(Pointcut_Builder.new.class_array([Foo6,Bar6]).method_accessor(true).build)
    @transactionAspectAccessors.add_behaviour(:instead,lambda do |metodo,orig_method,*args|
      if @undo_self.nil?
        @undo_self= metodo.receiver.clone
      end
      @undo_self.send(orig_method.name,*args)
    end)

    @transaction_Aspect_Commit_Rollback=Aspect.new
    @transaction_Aspect_Commit_Rollback.pointcut=(Pointcut_Builder.new.class_array([Foo6,Bar6]).method_accessor(true).build.not.and(Pointcut_Builder.new.class_array([Foo6,Bar6]).build))
    @transaction_Aspect_Commit_Rollback.add_behaviour(:after, lambda do |metodo, res|
      if @undo_self.nil?
        @undo_self= metodo.receiver.clone
      end
      @undo_self.instance_variables.each do |var|
        metodo.receiver.instance_variable_set(var,@undo_self.instance_variable_get(var))
      end
    end)
    @transaction_Aspect_Commit_Rollback.add_behaviour(:on_error,lambda do |metodo,e|
      @undo_self= metodo.receiver.clone
    end)

    @foo=Foo6.new
  end

  it 'should save on a different object' do
    @foo.otro=(8)
    @foo.instance_variable_get(:@otro).should be_nil
  end

  it 'should commit' do
    @foo.otro=(8)
    @foo.heavy(4)#commit
    @foo.instance_variable_get(:@otro).should == 8
    @foo.otro.should == 8
    @foo.otro=(19)
    @foo.otro.should == 19
    @foo.instance_variable_get(:@otro).should == 8
  end

  it 'should rollback' do
    @foo.otro=(8)
    @foo.heavy(4)#commit
    @foo.otro=(19)
    @foo.heavy(-1)#rollback
    @foo.instance_variable_get(:@otro).should == 8
    @foo.otro.should == 8
  end
end