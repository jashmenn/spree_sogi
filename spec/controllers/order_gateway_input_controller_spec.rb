require File.dirname(__FILE__) + '/../spec_helper'

describe OrderGatewayInputController do
  before(:each) do
    @raw_xml = File.read(SOGI_FIXTURES_PATH + "/sample_xml/amazon_order_sample.xml")
  end

  def do_create
    post 'create', :input_order_format => 'amazon', :body => @raw_xml
  end

  it "should have the right routes" do
    params_from(:get, "/sogi/orders/create/amazon.xml").should == {
      :controller => "order_gateway_input_controller",
      :action => "create",
      :input_order_format => "amazon",
      :format => "xml"
    }

    params_from(:get, "/sogi/orders/create/ebay.xml").should == {
      :controller => "order_gateway_input_controller",
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
  end

  it "POST 'create' should respond with errors if the orders already exist" do
    do_create
    response.should be_kind_of_success

    do_create
    response.should_not be_kind_of_success
    assigns(:orders).should have_at_most(0).orders
    assigns(:errors).should have_at_least(2).errors
  end

  it "POST 'create' should respond with split response if some passed and some failed" do
    pending "creating a fixture to test this scenario"
  end

  it "'create' should respond with an error if an unknown parser is attempted" do
    post 'create', :input_order_format => 'asdfasdfasdf', :body => @raw_xml
    response.should_not be_kind_of_success
  end


end
