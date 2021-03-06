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
    @order_creator = Sogi::OrderCreator.new(:origin_account_short_name => "my_test_store", :origin_account_transaction_identifier => "123456789")
    @order_creator.parser = @parser =  Sogi::Parser::Amazon.new(File.read(SOGI_FIXTURES_PATH + "/sample_xml/amazon_order_sample.xml"))
    @order = @order_creator.create_order(@parser.orders[0]) # just create the inital order so we can test it
    @default_tax_category = TaxCategory.create(:name => "default", :description => "default tax category")
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
    original_orders_size = Order.find(:all).size
    @order_creator.parser = @parser =  Sogi::Parser::Amazon.new(File.read(SOGI_FIXTURES_PATH + "/sample_xml/amazon_order_sample.xml"))
    lambda { @order_creator.create_order(@parser.orders[0]) }.should raise_error(Sogi::OrderCreator::OrderAlreadyExistsError)
    # should also check that no extra orders get created
    current_orders_size = Order.find(:all).size
    current_orders_size.should eql(original_orders_size)
  end

  it "should billing information" do
    bill_address = @order.creditcard_payment.address
    bill_address.should_not be_nil

    bill_address.firstname.should eql("Joe")
    bill_address.lastname.should eql("Smith")
    bill_address.phone.should eql("206-555-1234")
  end

  it "should use the shipping address if billing address isn't available" do
    bill_address = @order.creditcard_payment.address

    bill_address.address1.should eql("1234 Main St.")
    bill_address.city.should eql("Seattle")
    bill_address.state.name.should eql("Washington")
    bill_address.zipcode.should eql("98004")
    bill_address.country.iso.should eql("US")
  end

  it "should have a billing email address" do
    bill_address = @order.creditcard_payment.address
    bill_address.email.should eql("joesmith@hotmail.com")
  end

  it "should create a creditcard payment" do
    payment = @order.creditcard_payment
    payment.should_not be_nil
    bill_address = payment.address
    bill_address.should_not be_nil
    bill_address.firstname.should eql("Joe")
  end


  # ship_address is depricated. use order#address
  it "should have a shipping address" do
    ship_address = @order.address
    ship_address.should_not be_nil
    ship_address.addressable.should_not be_nil
    ship_address.addressable.should eql(@order)

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

    product.tax_category.should_not be_nil
    product.tax_category.id.should eql(@default_tax_category.id)
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
    item.origin_order_item_identifier .should eql("12345678901234")
  end

  it "should record the custom line item information" do
    # note: for now most custom data is put as a string into the line-items
    # special instructions field. however, ideally this would be changed to a
    # data-type for line items. for now, this is all i need, but don't be
    # surprised when we add this in. its ok to change this test in that
    # circumstance.

    @order_creator.create_order(@parser.orders[1])
    order = Order.find(:last)
    line_items = order.line_items

    line_items.should have_exactly(1).items
    item = line_items.first
    item.special_instructions.should eql("FooCustomOneKey: FooCustomOneValue, FooCustomTwoKey: FooCustomTwoValue")
  end

  it "should store custom information such as origin_channel and origin_channel_id" do
    @order.origin_channel.should eql("amazon")
    @order.origin_account_identifier.should eql("My Store")
    @order.origin_order_identifier.should eql("050-1234567-1234568")
    @order.ordered_at.should be_a_kind_of(Time)
    @order.ordered_at.to_i.should eql(1020295215) # "2002-05-01T15:20:15-08:00" 
    @order.posted_at.should be_a_kind_of(Time)
    @order.posted_at.to_i.should eql(1020295309)  # "2002-05-01T15:21:49-08:00"
  end

  it "should record information about fullfillment methods and service levels" do
    @order.properties.read_value(:origin_fulfillment_method).should eql("Ship")

    @order.shipments.should have_exactly(1).shipment
    @order.shipments.first.shipping_method.should_not be_nil
    @order.shipments.first.shipping_method.name.should eql("Standard")
  end


  it "should store the initial state as specified" do
    @order.state.should eql('paid')
  end

  it "should store the short name of the origin account we are using" do
    # this is so we can respond to the origin channel
    @order.origin_account_short_name.should eql("my_test_store")
  end

  it "should store the origin transaction id" do
    # this is so we can confirm that we downloaded the order
    @order.origin_account_transaction_identifier.should eql("123456789")
  end
              

  notes = <<-EOF
  then we just need to work on the controller being able to post this xml well
  then we need to setup phase three, tracking if this order has been sent to our fulfillment house or not
 
  should we go even further and create the origin channel as a full-on object? i dont want to get into that
  right now
  EOF

end
