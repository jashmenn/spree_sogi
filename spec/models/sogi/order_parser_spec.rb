require File.dirname(__FILE__) + '/../../spec_helper'

describe Sogi::OrderParser do
  before(:each) do
    @order_parser = Sogi::OrderParser.new
  end

  it "should be valid" do
    @order_parser.should be_valid
  end
end
