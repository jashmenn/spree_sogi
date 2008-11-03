require File.dirname(__FILE__) + '/../../../spec_helper'

describe Sogi::Parser::Amazon do
  before(:each) do
    @parser = Sogi::Parser::OrderMotion.new
    @parser.body = File.read(SOGI_FIXTURES_PATH + "/sample_xml/order_motion_order_sample.xml")
    @parser.body.should_not be_nil
    @parser.document.should_not be_nil
    @order = @parser.orders[0]
    @order.should_not be_nil
    @line_item = @order.line_items[0]
  end

  it "should know about the order numbers" do
    @order.order_id.should eql("16651")     # note that this is what OM calls OrderNumber
    @order.alt_id.should   eql("12303837")  # om calls this OrderID
  end

  it "should know about shipments" do
    @order.shipments.should_not be_nil
    @order.shipments.should have_exactly(1).shipment
  end

  it "should know about ship dates and they should be date objects" do
    @order.shipments[0].shipped_at.should eql("2006-02-09 14:47:00")
  end

  it "should know about tracking numbers" do
    @order.shipments[0].tracking_number.should eql("999999999999")
  end

  it "should know carrier information" do
    @order.shipments[0].carrier_name.should eql("FedEx")
    @order.shipments[0].carrier_service_code.should eql("13")
    @order.shipments[0].method_code.should eql("1")
    @order.shipments[0].method_name.should eql("FedEx Ground Residential")
  end

  # it should do a lot more things, but this is all i need for now
end

