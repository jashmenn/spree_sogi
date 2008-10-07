require File.dirname(__FILE__) + '/../../spec_helper'

describe Sogi::OrderParser do
  before(:each) do
    @order_parser = Sogi::OrderParser.new
  end

  it "should be valid" do
    @order_parser.should be_valid
  end

  # actual methods that should be tested by the order parser go here

  # wrongly placed tests below:
  # TODO XXX note, these tests below are totally wrong. these go in the amazon order parser
  # these tests should simply test the meta-information about the order and the dsl generation routines
  # todo, move these tests to the amazon order parser

  it "should know about various order numbers" do
  end

  it "should have information about dates" do
  end

  it "should have information about customers" do
  end

  it "should have information about recipients" do
  end

  it "should parse line items" do
  end

  it "should parse taxes" do
  end

  it "should parse shipping methods" do
  end

  it "should parse special instructions" do
  end

end

