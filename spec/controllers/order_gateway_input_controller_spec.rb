require File.dirname(__FILE__) + '/../spec_helper'

describe OrderGatewayInputController do
  self.use_transactional_fixtures = false

  before(:each) do
    OutsideOrderAttribute.destroy_all
    @raw_xml = File.read(SOGI_FIXTURES_PATH + "/sample_xml/amazon_order_sample.xml")
  end

  def do_create(body=nil)
    body ||= @raw_xml
    post 'create', :input_order_format => 'amazon', :body => body
  end

  it "should have the right routes" do
    params_from(:get, "/sogi/orders/create/amazon.xml").should == {
      :controller => "order_gateway_input",
      :action => "create",
      :input_order_format => "amazon",
      :format => "xml"
    }

    params_from(:get, "/sogi/orders/create/ebay.xml").should == {
      :controller => "order_gateway_input",
      :action => "create",
      :input_order_format => "ebay",
      :format => "xml"
    }
  end

  it "should use OrderGatewayInputController" do
    controller.should be_an_instance_of(OrderGatewayInputController)
  end

  it "POST 'create' should be successful with amazon" do
    do_create
    response.should be_kind_of_success
    assigns(:parser).should be_a_kind_of(Sogi::Parser::Amazon)
    assigns(:orders).should have_at_least(2).orders
    assigns(:errors).should have_at_most(0).errors
    OutsideOrderAttribute.find_all_by_origin_order_identifier("050-1234567-1234568").should have_exactly(1).attribute
  end

  it "POST 'create' should respond with errors if the orders already exist" do
    do_create
    response.should be_kind_of_success

    do_create
    response.code.should eql(accepted="202")
    assigns(:orders).should have_at_most(0).orders
    assigns(:errors).should have_at_least(2).errors
  end

  # it "POST 'create' should respond with split response if some passed and some failed" do
  # what causes this feed to fail? missing email addresses etc
  it "POST 'create' should respond with unprocessable response if some failed (even if some passed, they will rollback)" do
    OutsideOrderAttribute.find_all_by_origin_order_identifier("050-1234567-8327398").should have_exactly(0).attributes
    OutsideOrderAttribute.find_all_by_origin_order_identifier("902-1030835-1234560").should have_exactly(0).attributes
 
    do_create(File.read(SOGI_FIXTURES_PATH + "/sample_xml/amazon_partial_failure.xml"))
    response.code.should eql(unprocessable_entity="422")
    assigns(:orders).should have_at_most(0).orders
    assigns(:errors).should have_at_least(1).errors
    OutsideOrderAttribute.find_all_by_origin_order_identifier("050-1234567-8327398").should have_exactly(0).attributes
    OutsideOrderAttribute.find_all_by_origin_order_identifier("902-1030835-1234560").should have_exactly(0).attributes
  end

  it "'create' should respond with an error if an unknown parser is attempted" do
    post 'create', :input_order_format => 'asdfasdfasdf', :body => @raw_xml
    response.should_not be_kind_of_success
  end


end
