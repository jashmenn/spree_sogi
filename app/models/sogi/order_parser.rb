require 'hpricot'
require 'ostruct'

# abstract class
class Sogi::OrderParser

  module XmlParsingClassMethods
    # attr_at_xpath :order_id, "/AmazonOrderID"
    # then the custom data fields just specify what you want to go into custom data,
    # by default calls the method of the same key name
    def attr_at_xpath(symbol, xpath)
      define_method symbol do
        value_of xpath
      end
    end

    def attr_at_xpath_attribute(method_name, attribute, xpath)
      define_method method_name do
        value_of_attribute(xpath, attribute)
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

    def value_of_attribute(xpath, attribute_name)
      element = @document.at(xpath)
      return nil unless element
      element[attribute_name]
    end

  end


  # thin object to represent a particular order contained in the document
  class Order
    include XmlParsingInstanceMethods
    attr_accessor :document

    # FAIL class variables used like this is wrong, not inheritable
    @@custom_attributes_and_instructions = {}
    @@initial_order_state = nil
    cattr_accessor :initial_order_state

    class << self
      include XmlParsingClassMethods

      def custom_order_attribute(custom_key, value_instruction=nil)
        @@custom_attributes_and_instructions[custom_key] = value_instruction
      end

      def custom_attributes_and_instructions
        @@custom_attributes_and_instructions
      end
    end

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

    # todo, unify w/ above
    def shipments
      ret = []
      elements = @document.search self.shipments_found_in
      elements.each do |element| 
        li = Shipment.new
        li.document = element
        ret << li
      end
      ret
    end

    def initial_state
      self.class.initial_order_state
    end

    # stub methods
    def billing_email; end
    def billing_address_one; end
    def billing_address_two; end
    def billing_city; end
    def billing_zip; end
    def billing_state; end
    def billing_country; end

  end

  class LineItem
    class << self
      include XmlParsingClassMethods
    end

    include XmlParsingInstanceMethods
    attr_accessor :document
  end

  class Shipment
    class << self
      include XmlParsingClassMethods
    end

    include XmlParsingInstanceMethods
    attr_accessor :document
  end


  include XmlParsingInstanceMethods
  attr_accessor :body
  attr_accessor :document

  class << self
    include XmlParsingClassMethods

    # add a custom attribute that should be saved for each order
    def custom_order_attribute(custom_key, value_instruction=nil)
      Order.custom_order_attribute(custom_key, value_instruction)
    end

    def define_order_methods_as(&block)
      Order.class_eval &block
    end

    def define_line_item_methods_as(&block)
      LineItem.class_eval &block
    end

    def define_shipment_methods_as(&block)
      Shipment.class_eval &block
    end

    def set_order_state_to(initial_state)
      Order.initial_order_state = initial_state
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
    @document = new_body ? Hpricot.XML(new_body) : nil
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
