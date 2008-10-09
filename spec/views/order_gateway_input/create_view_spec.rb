require File.dirname(__FILE__) + '/../../spec_helper'

module MockOrderHelper
  def mock_order
    order = mock("order",
                 :id => (rand * 1000).to_i.to_s,
                 :origin_order_identifier => (rand * 1000).to_i.to_s)
  end
end

describe "/order_gateway_input/create" do
  include MockOrderHelper

  before do
  end

  it "should render order confirmations" do
    assigns[:orders] = [mock_order, mock_order]
    assigns[:errors] = []
    render 'order_gateway_input/create'

    response.should have_tag("order") 
    response.should have_tag("origin_id") 
  end

  it "should render order errors" do
    assigns[:orders] = []
    assigns[:errors] = [NameError.new("foo bar")]
    render 'order_gateway_input/create'

    response.should have_tag("errors") 
    response.should have_tag("error") 

    response.should_not have_tag("order") 
    response.should_not have_tag("origin_id") 
  end

  it "should render a combination" do
    pending "dealing with split pass/failed orders"
  end
  
end
