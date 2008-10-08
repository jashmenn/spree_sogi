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
    original_count = Product.find(:all).size

    # should create a product
    product = @order_creator.send(:find_or_create_product_for, line_item)
    Product.find(:all).should have_exactly(original_count + 1).products

    # should find a product
    product2 = @order_creator.send(:find_or_create_product_for, line_item)
    Product.find(:all).should have_exactly(original_count + 1).products

    product2.id.should eql(product.id)
  end

  it "should have line items" do
    pending "creating line items for unknown items"
    line_items = @order.line_items
    line_items.should have_at_least(2).items
    item = line_items.first
    item.should_not be_nil
    # assert stuff about the line items here
    # taxes, shipping
    # check quantities
    # check prices
    # check skus as well
  end

  it "should create needed tax zones" do
    pending "making sure this is how you want to use it"  
  end

  it "should record the correct tax collected information" do
    pending "seeing if there is a good place for it in the current database, then maybe adding it to the db"
  end

  notes = <<-EOF
  once we get the line items and taxes, we are basically done! 
  then we just need to work on the controller being able to post this xml well

  then we need to setup phase three, tracking if this order has been sent to our fulfillment house or not
  EOF

end
