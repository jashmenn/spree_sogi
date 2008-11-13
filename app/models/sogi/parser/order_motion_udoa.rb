# NOTE
# OM has multiple ways they can return an order (dumb). That is why you have
# this class as well as the other this is just a stub, add more information as
# you need it.
#
# this class currently unused, may be deleted
class Sogi::Parser::OrderMotionUDOA < Sogi::OrderParser
  # def orders_found_in
  #   "/OrderInformationResponse"
  # end

  # def origin_channel
  #   "order_motion"
  # end
  # set_order_state_to 'paid'

  # define_order_methods_as do

  #   def shipments_found_in
  #     "/ShippingInformation"
  #   end

  #   attr_at_xpath :order_id,              "/OrderHeader/OrderNumber"
  #   attr_at_xpath :alt_id,                "/OrderHeader/OrderID"
  # end

  # define_shipment_methods_as do
  #   attr_at_xpath :tracking_number,    "/Shipment/TrackingNumber"
  #   attr_at_xpath :shipped_at,         "/Shipment/ShipDate"

  #   <Method code="1" fulfillmentCode="GND" fulfillmentIndicator="" carrierServiceCode="13" carrierName="FedEx">FedEx Ground Residential</Method>
  #   attr_at_xpath_attribute :carrier_name,         'carrierName',        "/Method"
  #   attr_at_xpath_attribute :method_code,          'code',               "/Method"
  #   attr_at_xpath_attribute :carrier_service_code, 'carrierServiceCode', "/Method"
  #   attr_at_xpath :method_name,         "/Method"
  # end

end
