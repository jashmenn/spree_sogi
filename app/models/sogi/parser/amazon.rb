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
    def order_id; v("/AmazonOrderID"); end
  end

end
