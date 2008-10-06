require File.dirname(__FILE__) + '/../spec_helper'

describe OrderGatewayInputController do

  #Delete these examples and add some real ones
  it "should use OrderGatewayInputController" do
    controller.should be_an_instance_of(OrderGatewayInputController)
  end


  it "GET 'create' should be successful" do
    get 'create'
    response.should be_success
  end
end
