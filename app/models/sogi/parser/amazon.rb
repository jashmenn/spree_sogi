class Sogi::Parser::Amazon < Sogi::OrderParser
  custom_order_data :amazon_merchant_identifier, "/AmazonEnvelope/Header/MerchantIdentifier"

  def orders_found_in
    "/AmazonEnvelope/Message/OrderReport"
  end

  define_order_methods_as do
    def order_id; v("/AmazonOrderID"); end
  end

end
