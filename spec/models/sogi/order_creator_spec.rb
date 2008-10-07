require File.dirname(__FILE__) + '/../../spec_helper'

describe Sogi::OrderCreator do
  before(:each) do
    mock_country = mock("country", :null_object => true)
    # Country.should_receive(:find_by_iso).at_least(:once).and_return mock_country

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
    pending "write"
  end

  it "should have a billing address" do
    bill_address = @order.bill_address
    bill_address.should_not be_nil

    bill_address.firstname.should eql("Joe")
    bill_address.lastname.should eql("Smith")
    bill_address.phone.should eql("206-555-1234")
  end

  it "should have a billing email address" do
    pending "figuring out where to put this in the spree database"
     # attr_at_xpath :billing_email,         "/BillingData/BuyerEmailAddress"
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

  it "should have line items" do
  end


end
