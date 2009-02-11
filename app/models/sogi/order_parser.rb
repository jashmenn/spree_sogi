class Sogi::OrderParser
  def self.new_parser_for(parser_name)
    begin
      klass = "Sogi::Parser::#{parser_name.camelize}".constantize 
      return klass.new
    rescue NameError
      return nil
    end
  end
end

