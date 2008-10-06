require File.dirname(__FILE__) + '/../spec_helper'

describe OrderGatewayInputController do

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

  it "GET 'create' should be successful" do
    get 'create'
    response.should be_success
  end
end
