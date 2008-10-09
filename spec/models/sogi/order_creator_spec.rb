require File.dirname(__FILE__) + '/../../spec_helper'

module OrderCreatorHelperMethods
  def mock_line_item
    line_item = stub("line_item",
                     :order_code      => "1324",
                     :sku             => "thesku",
                     :title           => "mock parsed line item",
                     :tax_code        => nil,
                     :gift_message    => nil,
                     :quantity        => 1,
                     :price           => 20.00,
                     :shipping_price  => 3.00,
                     :tax             => 0.34,
                     :shipping_tax    => 0.00)
  end
end

describe Sogi::OrderCreator do
  include OrderCreatorHelperMethods

  before(:each) do
    @order_creator = Sogi::OrderCreator.new
    @order_creator.parser = @parser =  Sogi::Parser::Amazon.new(File.read(SOGI_FIXTURES_PATH + "/sample_xml/amazon_order_sample.xml"))
    @order = @order_creator.create_order(@parser.orders[0]) # just create the inital order so we can test it
   end

  it "should have the objects we want" do
    @order_creator.should_not be_nil
    @parser.should_not be_nil
    @order.should_not be_nil
    @order.should be_an_instance_of(Order)
  end

  it "should create the orders in the parser" do
    original_count = Order.find(:all).size
    @order_creator.create_order(@parser.orders[1])
    Order.find(:all).should have_exactly(original_count + 1).orders
  end

  it "should raise an exception if the existing order exists in that channel" do
    @order_creator.parser = @parser =  Sogi::Parser::Amazon.new(File.read(SOGI_FIXTURES_PATH + "/sample_xml/amazon_order_sample.xml"))
    lambda { @order_creator.create_order(@parser.orders[0]) }.should raise_error(Sogi::OrderCreator::OrderAlreadyExistsError)
  end

  it "should have a billing address" do
    bill_address = @order.bill_address
    bill_address.should_not be_nil

    bill_address.firstname.should eql("Joe")
    bill_address.lastname.should eql("Smith")
    bill_address.phone.should eql("206-555-1234")
  end

  it "should have a billing email address" do
    bill_address = @order.bill_address
    bill_address.email.should eql("joesmith@hotmail.com")
  end

  it "should have a shipping address" do
    ship_address = @order.ship_address
    ship_address.should_not be_nil

    ship_address.firstname.should eql("Joe")
    ship_address.lastname.should eql("Smith")
    ship_address.phone.should eql("206-555-1234")
    ship_address.address1.should eql("1234 Main St.")
    ship_address.city.should eql("Seattle")
    ship_address.state.name.should eql("Washington")
    ship_address.zipcode.should eql("98004")
    ship_address.country.iso.should eql("US")
  end

  it "should create a product for an unknown line item" do
    line_item = mock_line_item
    line_item.should_not be_nil

    original_count = Product.find(:all).size
    @order_creator.send(:create_product_for, line_item)
    Product.find(:all).should have_exactly(original_count + 1).products

    products = Product.for_sku line_item.sku
    product = products.first
    product.should_not be_nil
    product.name.should eql(line_item.title)
    product.master_price.should eql(line_item.price)
  end

  it "should find_or_create a line-item's product appropriately" do
    line_item = mock_line_item

    original_count = Product.find(:all).size

    # should create a product
    product = @order_creator.send(:find_or_create_product_for, line_item)
    Product.find(:all).should have_exactly(original_count + 1).products

    # should find a product
    product2 = @order_creator.send(:find_or_create_product_for, line_item)
    Product.find(:all).should have_exactly(original_count + 1).products

    product2.id.should eql(product.id)
  end

  it "should have line items with price and tax information" do
    line_items = @order.line_items
    line_items.should have_at_least(2).items
    item = line_items.first
    item.should_not be_nil

    item.price.to_d           .should eql(10.00.to_d)
    item.ship_amount.to_d     .should eql(3.49.to_d)
    item.tax_amount.to_d      .should eql(1.29.to_d)
    item.ship_tax_amount.to_d .should eql(0.24.to_d)

    item.quantity             .should eql(1)
    item.sku                  .should eql("1234")
  end

  it "should store custom information such as origin_channel and origin_channel_id" do
    @order.origin_channel.should eql("amazon")
    @order.origin_account_identifier.should eql("My Store")
    @order.origin_order_identifier.should eql("050-1234567-1234567")
    @order.ordered_at.should be_a_kind_of(Time)
    @order.ordered_at.to_i.should eql(1020295215) # "2002-05-01T15:20:15-08:00" 
    @order.posted_at.should be_a_kind_of(Time)
    @order.posted_at.to_i.should eql(1020295309)  # "2002-05-01T15:21:49-08:00"
  end

  it "should record information about fullfillment methods and service levels" do
    pending "figuring out how to handle shipping information, is there an existing plugin?"
    # <FulfillmentMethod>Ship</FulfillmentMethod>
    # <FulfillmentServiceLevel>Standard</FulfillmentServiceLevel>
  end
              

  notes = <<-EOF
  then we just need to work on the controller being able to post this xml well
  then we need to setup phase three, tracking if this order has been sent to our fulfillment house or not
 
  should we go even further and create the origin channel as a full-on object? i dont want to get into that
  right now
  EOF

end
