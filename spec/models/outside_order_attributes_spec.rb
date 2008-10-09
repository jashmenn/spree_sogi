require File.dirname(__FILE__) + '/../spec_helper'

describe OutsideOrderAttribute do
  before(:each) do
    @outside_order_attribute = OutsideOrderAttribute.new
  end

  it "should be valid" do
    @outside_order_attribute.should be_valid
  end
end
