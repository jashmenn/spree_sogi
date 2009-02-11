require File.dirname(__FILE__) + '/../../spec_helper'

describe Sogi::XmlOrderParser do
  before(:each) do
    @order_parser = Sogi::XmlOrderParser.new
    @order_parser.body = File.read(SOGI_FIXTURES_PATH + "/sample_xml/amazon_order_sample.xml")
    @order_parser.body.should_not be_nil
    @order_parser.document.should_not be_nil
  end

  it "should be valid" do
    @order_parser.should_not be_nil 
  end

  # todo, test the meta actions of this class

  it "should get an instance of a correct parser given a short name" do
    parser = Sogi::XmlOrderParser.new_parser_for("amazon")
    parser.should_not be_nil
    parser.should be_a_kind_of(Sogi::Parser::Amazon)

    parser = Sogi::XmlOrderParser.new_parser_for("asdfasdfasdf")
    parser.should be_nil
  end

end

