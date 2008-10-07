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


  define_order_methods_as do

    def line_items_found_in
      "/Item"
    end

    # attr_at_xpath :order_id, "/AmazonOrderID"
    # then the custom data fields just specify what you want to go into custom data,
    # by default calls the method of the same key name

    def order_id             ; v "/AmazonOrderID"                           ; end

    def ordered_at           ; v "/OrderDate"                               ; end
    def posted_at            ; v "/OrderPostedDate"                         ; end

    def billing_email        ; v "/BillingData/BuyerEmailAddress"           ; end
    def billing_name         ; v "/BillingData/BuyerName"                   ; end
    def billing_phone_number ; v "/BillingData/BuyerPhoneNumber"            ; end

    def fulfillment_method   ; v "/FulfillmentData/FulfillmentMethod"       ; end
    def fulfillment_level    ; v "/FulfillmentData/FulfillmentServiceLevel" ; end
 
    def shipping_name        ; v "/FulfillmentData/Address/Name"            ; end
    def shipping_address_one ; v "/FulfillmentData/Address/AddressFieldOne" ; end
    def shipping_city        ; v "/FulfillmentData/Address/City"            ; end
    def shipping_state       ; v "/FulfillmentData/Address/StateOrRegion"   ; end
    def shipping_zip         ; v "/FulfillmentData/Address/PostalCode"      ; end
    def shipping_country     ; v "/FulfillmentData/Address/CountryCode"     ; end
    def shipping_phone       ; v "/FulfillmentData/Address/PhoneNumber"     ; end
  end


  define_line_item_methods_as do
    def order_code     ; v "/AmazonOrderItemCode"    ; end
    def sku            ; v "/SKU"                    ; end
    def title          ; v "/Title"                  ; end
    def quantity       ; v("/Quantity").to_i         ; end
    def tax_code       ; v "/ProductTaxCode"         ; end

    def price          ; price_method("Principal")   ; end
    def shipping_price ; price_method("Shipping")    ; end
    def tax            ; price_method("Tax")         ; end
    def shipping_tax   ; price_method("ShippingTax") ; end

    def gift_message   ; v "/GiftMessageText"        ; end

			 
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
