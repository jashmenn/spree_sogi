require 'hpricot'
require 'ostruct'

# abstract class
class Sogi::OrderParser

  # helper methods for easy parsing of the document
  module XmlParsingHelperMethods
    # a path to always search when using "value_of"
    def value_of_prefix; ""; end

    def value_of(xpath)
      @document.at(value_of_prefix + xpath).inner_html
    end
    alias_method :v, :value_of
  end

  # thin object to represent a particular order contained in the document
  class Order < OpenStruct
    attr_accessor :document
    include XmlParsingHelperMethods
  end

  attr_accessor :body
  attr_accessor :document

  class << self

    def custom_order_data(key, xpath)
    end

    def define_order_methods_as(&block)
      Order.class_eval &block
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
