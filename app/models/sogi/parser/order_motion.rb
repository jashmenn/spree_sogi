# still has much work todo, but should currently provide basic shipping information
# more to come...
class Sogi::Parser::OrderMotion < Sogi::XmlOrderParser
  def orders_found_in
    "/OrderInformationResponse"
  end

  def origin_channel
    "order_motion"
  end
  set_order_state_to 'paid'

#  attr_at_xpath :merchant_identifier, "/AmazonEnvelope/Header/MerchantIdentifier"

  # custom_order_attribute :origin_fulfillment_method, :fulfillment_method
  # custom_order_attribute :origin_fulfillment_level, :fulfillment_level

  define_order_methods_as do

  #   def line_items_found_in
  #     "/Item"
  #   end

    def shipments_found_in
      "/ShippingInformation"
    end

    attr_at_xpath :order_id,              "/OrderHeader/OrderNumber"
    attr_at_xpath :alt_id,                "/OrderHeader/OrderID"
#     attr_at_xpath :ordered_at,            "/OrderDate"

  #   attr_at_xpath :ordered_at,            "/OrderDate"
  #   attr_at_xpath :posted_at,             "/OrderPostedDate"

  #   attr_at_xpath :billing_email,         "/BillingData/BuyerEmailAddress"
  #   attr_at_xpath :billing_name,          "/BillingData/BuyerName"
  #   attr_at_xpath :billing_phone_number,  "/BillingData/BuyerPhoneNumber"

  #   attr_at_xpath :fulfillment_method,    "/FulfillmentData/FulfillmentMethod"
  #   attr_at_xpath :fulfillment_level,     "/FulfillmentData/FulfillmentServiceLevel"
 
  #   attr_at_xpath :shipping_name,         "/FulfillmentData/Address/Name"
  #   attr_at_xpath :shipping_address_one,  "/FulfillmentData/Address/AddressFieldOne"
  #   attr_at_xpath :shipping_address_two,  "/FulfillmentData/Address/AddressFieldTwo" # does this even exist?
  #   attr_at_xpath :shipping_city,         "/FulfillmentData/Address/City"
  #   attr_at_xpath :shipping_state,        "/FulfillmentData/Address/StateOrRegion"
  #   attr_at_xpath :shipping_zip,          "/FulfillmentData/Address/PostalCode"
  #   attr_at_xpath :shipping_country,      "/FulfillmentData/Address/CountryCode"
  #   attr_at_xpath :shipping_phone,        "/FulfillmentData/Address/PhoneNumber"
  end

  # define_line_item_methods_as do
  #   attr_at_xpath :order_code,    "/AmazonOrderItemCode"
  #   attr_at_xpath :sku,           "/SKU"
  #   attr_at_xpath :title,         "/Title"
  #   attr_at_xpath :tax_code,      "/ProductTaxCode"
  #   attr_at_xpath :gift_message,  "/GiftMessageText"

  #   def quantity       ; v("/Quantity").to_i         ; end
  #   def price          ; price_method("Principal")   ; end
  #   def shipping_price ; price_method("Shipping")    ; end
  #   def tax            ; price_method("Tax")         ; end
  #   def shipping_tax   ; price_method("ShippingTax") ; end

  #   def price_method(looking_for)
  #     price_elements = @document.search("/ItemPrice/Component")
  #     price_elements.each do |elem|
  #       if elem.at("/Type").inner_text =~ /^#{looking_for}$/
  #         return elem.at("/Amount").inner_text.to_f
  #       end
  #     end
  #     nil
  #   end

  #   returns hash key, values of custom attributes 
  #   def custom_attributes
  #     customs = {}
  #     custom_infos = @document.search("/CustomizationInfo")
  #     custom_infos.each do |elem|
  #       customs[elem.at("/Type").inner_text] = elem.at("/Data").inner_text
  #     end
  #     customs
  #   end

  # end

  define_shipment_methods_as do
    attr_at_xpath :tracking_number,    "/Shipment/TrackingNumber"
    attr_at_xpath :shipped_at,         "/Shipment/ShipDate"

    # <Method code="1" fulfillmentCode="GND" fulfillmentIndicator="" carrierServiceCode="13" carrierName="FedEx">FedEx Ground Residential</Method>
    attr_at_xpath_attribute :carrier_name,         'carrierName',        "/Method"
    attr_at_xpath_attribute :method_code,          'code',               "/Method"
    attr_at_xpath_attribute :carrier_service_code, 'carrierServiceCode', "/Method"
    attr_at_xpath :method_name,         "/Method"
  end

end
