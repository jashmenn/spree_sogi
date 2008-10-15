class OrderGatewayInputController < ApplicationController
  class BadParserError < Sogi::Error #:nodoc:
  end
  rescue_from BadParserError, :with => :show_error
  skip_before_filter :verify_authenticity_token

  # POST '/sogi/orders/create/:input_order_format.xml'
  def create
    @parser = Sogi::OrderParser.new_parser_for(params[:input_order_format])
    raise BadParserError, "Unknown order format" unless @parser

    @parser.body = params[:body]

    @order_creator = Sogi::OrderCreator.new
    @order_creator.parser = @parser

    @orders, @errors = *@order_creator.create_orders!

    respond_to do |format|
      if @orders.size > 0
        format.xml  { render :status => :created }
      else
        format.xml  { render :status => :unprocessable_entity }
      end
    end
  end

  def show_error(exception); render :xml => exception, :status => :unprocessable_entity; end

end

