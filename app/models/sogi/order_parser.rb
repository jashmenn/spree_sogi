require 'hpricot'
require 'ostruct'

# abstract class
class Sogi::OrderParser

  module XmlParsingClasMethods
    # attr_at_xpath :order_id, "/AmazonOrderID"
    # then the custom data fields just specify what you want to go into custom data,
    # by default calls the method of the same key name
    def attr_at_xpath(symbol, xpath)
      define_method symbol do
        value_of xpath
      end
    end
  end

  # helper methods for easy parsing of the document
  module XmlParsingInstanceMethods
    # a path to always search when using "value_of"
    def value_of_prefix; ""; end

    # returns the inner html of a given xpath
    def value_of(xpath)
      found_elem = @document.at(value_of_prefix + xpath)
      return nil unless found_elem
      found_elem.inner_html
    end
    alias_method :v, :value_of
  end


  # thin object to represent a particular order contained in the document
  class Order
    include XmlParsingInstanceMethods
    attr_accessor :document

    class << self
      include XmlParsingClasMethods
      # def add_custom_data(key, xpath)
      #   @@custom_data ||= {}
      #   @@custom_data[key] = xpath

      #   define_method key do
      #     read_custom_data(key)
      #   end
      # end
    end

    # def initialize
    #   super
    # end

    # def read_custom_data(key)
    #   v(@@custom_data[key])
    # end
    # protected :read_custom_data

    # def custom_data
    #   @@custom_data ||= {}
    # end

    def line_items
      ret = []
      elements = @document.search self.line_items_found_in
      elements.each do |element| 
        li = LineItem.new
        li.document = element
        ret << li
      end
      ret
    end

  end

  class LineItem
    class << self
      include XmlParsingClasMethods
    end

    include XmlParsingInstanceMethods
    attr_accessor :document
  end

  include XmlParsingInstanceMethods
  attr_accessor :body
  attr_accessor :document

  class << self
    include XmlParsingClasMethods

    # def custom_order_data(key, xpath)
    #   Order.add_custom_data(key, xpath)
    # end

    def define_order_methods_as(&block)
      Order.class_eval &block
    end

    def define_line_item_methods_as(&block)
      LineItem.class_eval &block
    end

    def new_parser_for(parser_name)
      begin
        klass = "Sogi::Parser::#{parser_name.camelize}".constantize 
        return klass.new
      rescue NameError
        return nil
      end
    end

  end

  def initialize(body=nil)
    self.body = body
  end

  def body=(new_body)
    @body = new_body
    @document = new_body ? Hpricot(new_body) : nil
  end

  def orders
    ret = []
    elements = @document.search self.orders_found_in
    elements.each do |element| 
      o = Order.new
      o.document = element
      ret << o
    end
    ret
  end


end
