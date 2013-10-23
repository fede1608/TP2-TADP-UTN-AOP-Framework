module Aspect_examples

  def logging
    require 'logger'
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    logger.formatter = lambda do |severity, datetime, progname, msg|
      "#{datetime} #{severity}: #{msg}\n"
    end
    logger.info "Iniciando Aspecto de loggeo"
    self.add_behaviour(:before, lambda {|met,*args| logger.info "Se ejecuto el metodo: #{met.name.to_s} de la Clase: #{met.owner.name} con los parametros: #{args.to_s}" })
    self.add_behaviour(:after, lambda {|met,res| logger.info "El resultado es: #{res.to_s}" })
  end

  def benchmarking
    require 'logger'
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    logger.formatter = lambda do |severity, datetime, progname, msg|
      "#{datetime} #{severity}: #{msg}\n"
    end
    self.add_behaviour(:before, lambda {|met,*arguments|@start_time = Time.now})
    self.add_behaviour(:after, lambda {|met,res|  logger.info (Time.now - @start_time).to_s + " have elapsed to execute Method: #{met.name.to_s} from Class: #{met.owner.name.to_s}"})
  end

end
class Aspect
  include Aspect_examples
end