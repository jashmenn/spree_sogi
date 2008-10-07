require File.dirname(__FILE__) + '/../../spec_helper'

describe Sogi::OrderParser do
  before(:each) do
    @order_parser = Sogi::OrderParser.new
    @order_parser.body = File.read(SOGI_FIXTURES_PATH + "/sample_xml/amazon_order_sample.xml")
    @order_parser.body.should_not be_nil
    @order_parser.document.should_not be_nil
  end

  it "should be valid" do
    @order_parser.should_not be_nil 
  end

  # todo, test the meta actions of this class

end

