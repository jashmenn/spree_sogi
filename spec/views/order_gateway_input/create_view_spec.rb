require File.dirname(__FILE__) + '/../../spec_helper'

describe "/order_gateway_input/create" do
  before do
    render 'order_gateway_input/create'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', 'Find me in app/views/order_gateway_input/create.rhtml')
  end
end
