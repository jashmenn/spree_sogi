require File.dirname(__FILE__) + '/../../spec_helper'

describe Sogi::OrderCreator do
  before(:each) do
    @order_creator = Sogi::OrderCreator.new
  end

  it "should be valid" do
    @order_creator.should be_valid
  end
end
