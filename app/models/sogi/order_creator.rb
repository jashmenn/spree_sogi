class Sogi::OrderCreator
  class Error < Sogi::Error #:nodoc:
  end

  attr_accessor :parser

  def create_orders!
    raise Error, "Need to set a parser before you can create orders." unless @parser
    raise Error, "No orders found to parse" unless orders = @parser.orders
    orders.each do |order|
      create_order(order)
    end
  end

  def create_order(order)
    Order.transaction do
      # check for existing order id, raise an exception
      new_order = Order.create

      create_order_billing_information(order, new_order)
      create_order_shipping_information(order, new_order)
      create_order_line_items(order, new_order)

      new_order.save
      new_order
    end
  end

=begin

will be custom: 
    merchant id 
    attr_at_xpath :order_id,              "/AmazonOrderID"

should just add these into the order model anyway
    attr_at_xpath :ordered_at,            "/OrderDate"
    attr_at_xpath :posted_at,             "/OrderPostedDate"

    attr_at_xpath :fulfillment_method,    "/FulfillmentData/FulfillmentMethod"
    attr_at_xpath :fulfillment_level,     "/FulfillmentData/FulfillmentServiceLevel"
 
  end

=end

  private

  def create_order_billing_information(order, new_order)
      # add billing information
      first, last = order.billing_name.split(/ /, 2)
      billing = Address.create(:firstname => first, 
                               :lastname => last, 
                               :phone => order.billing_phone_number, 
                               :country_id => Spree::Config[:default_country_id])
      # attr_at_xpath :billing_email,         "/BillingData/BuyerEmailAddress"
      new_order.bill_address = billing
  end

  def create_order_shipping_information(order, new_order)
      # add shipping_information
      shipping_country = Country.find_by_iso(order.shipping_country) || Spree::Config[:default_country_id]
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

=begin
    attr_at_xpath :order_code,    "/AmazonOrderItemCode"
    attr_at_xpath :sku,           "/SKU"
    attr_at_xpath :title,         "/Title"
    attr_at_xpath :tax_code,      "/ProductTaxCode"
    attr_at_xpath :gift_message,  "/GiftMessageText"

    def quantity       ; v("/Quantity").to_i         ; end
    def price          ; price_method("Principal")   ; end
    def shipping_price ; price_method("Shipping")    ; end
    def tax            ; price_method("Tax")         ; end
    def shipping_tax   ; price_method("ShippingTax") ; end
=end

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

end
