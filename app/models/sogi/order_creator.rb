class Sogi::OrderCreator
  class Error < Sogi::Error #:nodoc:
  end

  class OrderAlreadyExistsError < Error #:nodoc:
  end

  attr_accessor :parser

  def create_orders!
    raise Error, "Need to set a parser before you can create orders." unless @parser
    raise Error, "No orders found to parse" unless parser_orders = @parser.orders
    # todo, should be able to handle split orders where some pass and some fail here
    orders, errors = [], []
    parser_orders.each do |order|
      begin
        orders << create_order(order)
      rescue => e
        errors << e
      end
    end
    [orders, errors]
  end

  def create_order(order)
    Order.transaction do
      # check for existing order id, raise an exception
      # you really shouldn't implement this until you get the order data. then you just use the validations
      # in that object to test if we can create this object

      new_order = Order.create
      new_order.save

      create_and_verify_outside_order_attributes(order, new_order)
      create_order_billing_information(order, new_order)
      create_order_shipping_information(order, new_order)
      create_order_line_items(order, new_order)
      create_order_custom_data(order, new_order)

      new_order.state = order.initial_state if order.initial_state 

      new_order.save
      new_order
    end
  end

=begin

What to do w/ these? order custom?

    attr_at_xpath :fulfillment_method,    "/FulfillmentData/FulfillmentMethod"
    attr_at_xpath :fulfillment_level,     "/FulfillmentData/FulfillmentServiceLevel"
 
=end

  private

  def create_order_billing_information(order, new_order)
      shipping_country = Country.find_by_iso(order.shipping_country) || Country.find(Spree::Config[:default_country_id])

      # add billing information
      first, last = order.billing_name.split(/ /, 2)
      billing = Address.create(:firstname => first, 
                               :lastname => last, 
                               :phone => order.billing_phone_number, 
                               :email => order.billing_email,
                               :country_id => shipping_country.id)
      # attr_at_xpath :billing_email,         "/BillingData/BuyerEmailAddress"
      new_order.bill_address = billing
      billing.addressable = new_order # why do i have to do this?
      billing.save
  end

  def create_order_shipping_information(order, new_order)
      # add shipping_information
      shipping_country = Country.find_by_iso(order.shipping_country) || Country.find(Spree::Config[:default_country_id])
      # state = State.find_or_create_by_name_and_country_id(order.shipping_state, shipping_country.id) # ... ?
      state = State.find_by_name(order.shipping_state)
    
      first, last = order.shipping_name.split(/ /, 2)
      shipping = Address.create(:firstname => first, 
                                :lastname => last, 
                                :phone => order.shipping_phone, 
                                :country_id => shipping_country.id,
                                :address1 => order.shipping_address_one,
                                :address2 => order.shipping_address_two,
                                :city => order.shipping_city,
                                :state_id => state.id,
                                :zipcode => order.shipping_zip
                               )
      new_order.ship_address = shipping
      shipping.addressable = new_order
      shipping.save
  end

  def create_order_line_items(parser_order, new_order)
    parser_order.line_items.each do |parser_item|
      product = find_or_create_product_for(parser_item)
      variant = Variant.find(:first, :conditions => ["product_id = ? AND sku = ?", product.id, parser_item.sku])

      line_item = LineItem.create(:variant_id => variant.id,
                                  :quantity => parser_item.quantity,
                                  :price => parser_item.price,
                                  :ship_amount => parser_item.shipping_price,
                                  :tax_amount => parser_item.tax,
                                  :ship_tax_amount => parser_item.shipping_tax)
      new_order.line_items << line_item
    end
  end

  # TODO this will become more meta. you specify what data is going to be
  # custom fields in the PARSER and then define how to get that data. TODO
  # write this to use that
  #
  # for each custom order data specified,
  # if its a Symbol, its a method on the parsed order
  # if it is a String it is considered a literal value
  # if it is a Proc, call that proc with the parsed order
  #
  # write a custom property with that value
  def create_order_custom_data(porder, new_order)
    custom_attrs = porder.class.custom_attributes_and_instructions
    custom_attrs.each do |key,instruction|
      value = case instruction.class.to_s
              when 'String' then instruction
              when 'Symbol' then porder.send(instruction)
              when 'Proc'   then instruction.call(porder)
              else nil
              end
               
      new_order.properties.write key, value
    end
  end

  # does this method belong here? maybe not
  def create_product_for(line_item)
    product = Product.create(:name => line_item.title, 
                             :master_price => line_item.price, 
                             :description => line_item.title)
    product.variants.create(:product_id => product.id, :sku => line_item.sku, :price => line_item.price)
    product
  end

  def find_or_create_product_for(line_item)
    products = Product.by_sku line_item.sku
    if products.size > 0
      return products.first
    else
      return create_product_for(line_item)
    end
  end

  def create_and_verify_outside_order_attributes(porder, new_order)
    ooa = OutsideOrderAttribute.create(
      :origin_channel            => @parser.origin_channel,
      :origin_account_identifier => @parser.merchant_identifier,
      :origin_order_identifier   => porder.order_id,
      :ordered_at                => porder.ordered_at,
      :posted_at                 => porder.posted_at)
    unless ooa.valid?
      raise OrderAlreadyExistsError, 
      "Order origin_id #{porder.order_id} for #{@parser.origin_channel} account #{@parser.merchant_identifier} already exists"
    end
    ooa.order = new_order
    ooa.save
    ooa
  end

end
