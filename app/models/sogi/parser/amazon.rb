class Sogi::Parser::Amazon < Sogi::OrderParser
  # The point of custom order data is to specify data that will become custom
  # order data for the product. one issue is that this xpath is relative to the
  # entire document.  
  # 
  # Custom order data belongs to the parser, not the order? some should be in
  # the order, some should be in the parser. how do we handle this?
  #
  # custom_order_data :amazon_merchant_identifier, "/AmazonEnvelope/Header/MerchantIdentifier"

  def orders_found_in
    "/AmazonEnvelope/Message/OrderReport"
  end

  def origin_channel
    "amazon"
  end

  attr_at_xpath :merchant_identifier, "/AmazonEnvelope/Header/MerchantIdentifier"

  custom_order_attribute :origin_fulfillment_method, :fulfillment_method
  custom_order_attribute :origin_fulfillment_level, :fulfillment_level

  define_order_methods_as do
    # the custom data fields just specify what you want to go into custom data,
    # by default calls the method of the same key name

    def line_items_found_in
      "/Item"
    end

    attr_at_xpath :order_id,              "/AmazonOrderID"

    attr_at_xpath :ordered_at,            "/OrderDate"
    attr_at_xpath :posted_at,             "/OrderPostedDate"

    attr_at_xpath :billing_email,         "/BillingData/BuyerEmailAddress"
    attr_at_xpath :billing_name,          "/BillingData/BuyerName"
    attr_at_xpath :billing_phone_number,  "/BillingData/BuyerPhoneNumber"

    attr_at_xpath :fulfillment_method,    "/FulfillmentData/FulfillmentMethod"
    attr_at_xpath :fulfillment_level,     "/FulfillmentData/FulfillmentServiceLevel"
 
    attr_at_xpath :shipping_name,         "/FulfillmentData/Address/Name"
    attr_at_xpath :shipping_address_one,  "/FulfillmentData/Address/AddressFieldOne"
    attr_at_xpath :shipping_address_two,  "/FulfillmentData/Address/AddressFieldTwo" # does this even exist?
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

end
