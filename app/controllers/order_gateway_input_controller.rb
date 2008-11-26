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

    @order_creator = Sogi::OrderCreator.new(:origin_account_short_name => params[:origin_account_short_name], 
                                            :origin_account_transaction_identifier => params[:origin_account_transaction_identifier])
    @order_creator.parser = @parser

    @orders, @errors = *@order_creator.create_orders!

    respond_to do |format|
      # if @order.size == @parser.orders.size THEN we give success? no. orders will always be 0 if
      # changed this around, so no more multiple errors unless the error is 'already created'
      # todo, we still need to check for partial success

      if @orders.size > 0 && @errors.size < 1 
        format.xml  { render :status => :created }
      elsif contains_only_existing_order_errors?(@errors)
        @errors.each { |e| logger.warn "OrderCreator exisiting order: #{e.class}: #{e.message}" }
        format.xml  { render :status => :accepted } # 202 :accepted
      else
        error_message = @errors.inject("") { |memo,e| memo << "OrderCreator Exception: #{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}\n"; memo }
        SogiExtension.on_importing_error("OrderCreator Exceptions: #{@errors.first.message}", error_message) # if SogiExtension.respond_to?(:on_importing_error) 
        @errors.each { |e| logger.fatal "OrderCreator Exception: #{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}" }
        format.xml  { render :status => :unprocessable_entity }
      end
    end
  end

  def show_error(exception); render :xml => exception, :status => :unprocessable_entity; end

  private 
  def contains_only_existing_order_errors?(errors)
    return false unless errors && errors.size > 0
    return false if errors.detect {|e| !e.kind_of?(Sogi::OrderCreator::OrderAlreadyExistsError) } # if you find an error that is not this, then false
    return true
  end

end

