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

      # add billing information
      first, last = order.billing_name.split(/ /, 2)
      billing = Address.create(:firstname => first, 
                               :lastname => last, 
                               :phone => order.billing_phone_number, 
                               :country_id => Spree::Config[:default_country_id])
      # attr_at_xpath :billing_email,         "/BillingData/BuyerEmailAddress"
      new_order.bill_address = billing

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

      # add line items

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
 
    attr_at_xpath :shipping_name,         "/FulfillmentData/Address/Name"
    attr_at_xpath :shipping_address_one,  "/FulfillmentData/Address/AddressFieldOne"
    attr_at_xpath :shipping_city,         "/FulfillmentData/Address/City"
    attr_at_xpath :shipping_state,        "/FulfillmentData/Address/StateOrRegion"
    attr_at_xpath :shipping_zip,          "/FulfillmentData/Address/PostalCode"
    attr_at_xpath :shipping_country,      "/FulfillmentData/Address/CountryCode"
    attr_at_xpath :shipping_phone,        "/FulfillmentData/Address/PhoneNumber"
  end

  define_line_item_methods_as do
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

    def price_method(looking_for)
      price_elements = @document.search("/ItemPrice/Component")
      price_elements.each do |elem|
        if elem.at("/Type").inner_text =~ /^#{looking_for}$/
          return elem.at("/Amount").inner_text.to_f
        end
      end
      nil
    end
  end
=end

end
