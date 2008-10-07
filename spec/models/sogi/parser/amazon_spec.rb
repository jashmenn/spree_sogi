require File.dirname(__FILE__) + '/../../../spec_helper'

describe Sogi::Parser::Amazon do
  before(:each) do
    @parser = Sogi::Parser::Amazon.new
    @parser.body = File.read(SOGI_FIXTURES_PATH + "/sample_xml/amazon_order_sample.xml")
    @parser.body.should_not be_nil
    @parser.document.should_not be_nil
    @order = @parser.orders[0]
    @line_item = @order.line_items[0]
  end

  it "should know about various orders xml orders" do
    @parser.orders.should_not be_nil
    @parser.orders.size.should eql(2)
    @order.should_not be_nil
    @order.should respond_to(:order_id)
  end

  it "should know about various order numbers" do
    @order.order_id.should eql("050-1234567-1234567")
  end

  it "should have custom order data and know the merchant id" do
    # @order.custom_data.should have_at_least(1).items
    # @order.amazon_merchant_identifier.should eql("My Store")
    pending "figuring out how custom data will work"
  end

  it "should have information about dates" do
    @order.ordered_at.should eql("2002-05-01T15:20:15-08:00") # todo make it a Time object
    @order.posted_at.should eql("2002-05-01T15:21:49-08:00")  # todo make it a Time object
  end

  it "should have billing information" do
    @order.billing_email.should eql("joesmith@hotmail.com")
    @order.billing_name.should eql("Joe Smith")
    @order.billing_phone_number.should eql("206-555-1234")
  end

  it "should have shipping information" do
    @order.fulfillment_method.should eql("Ship")
    @order.fulfillment_level.should eql("Standard")
  end

  it "should have information about recipients" do
    @order.shipping_name.should eql("Joe Smith")
    @order.shipping_address_one.should eql("1234 Main St.")
    @order.shipping_city.should eql("Seattle")
    @order.shipping_state.should eql("Washington")
    @order.shipping_zip.should eql("98004")
    @order.shipping_country.should eql("US")
    @order.shipping_phone.should eql("206-555-1234")
  end

  it "should parse line items" do
    line_items = @order.line_items
    line_items.should have_at_least(2).items
  end

  it "should have basic line item information" do
    @line_item.order_code.should eql("12345678901234"
    @line_item.sku.should eql("1234")
    @line_item.title.should eql("Programming Perl, 3rd edition")
    @line_item.quantity.should eql(1)
    @line_item.tax_code.should eql("1234")
  end

  it "should parse line item price information" do
    @line_item.price.should eql(10.00)
    @line_item.shipping_price.should eql(3.49)
    @line_item.tax.should eql(1.29)
    @line_item.shipping_tax.should eql(0.24)
  end

  it "should parse line item special instructions" do
    @line_item.gift_message.should eql("We love you mom!")
  end

end

