class Sogi::OrderCreator
  class Error < Sogi::Error #:nodoc:
  end

  class OrderAlreadyExistsError < Error #:nodoc:
    attr_accessor :order_trying_to_create # ehhh im not sure i love this
    def initialize(order_trying_to_create)
      @order_trying_to_create = order_trying_to_create
    end
  end

  # raised if we have >0 errors
  class AtLeastPartialFailure < Error #:nodoc:
  end

  attr_accessor :parser

  attr_accessor :opts

  def initialize(opts={})
    @opts=opts
  end

  # Transaction to around creating all orders. If one fails
  # they all fail. Following Pragmatic Programmer's advice "fail early"
  def create_orders!
    raise Error, "Need to set a parser before you can create orders." unless @parser
    raise Error, "No orders found to parse" unless parser_orders = @parser.orders
    # todo, should be able to handle split orders where some pass and some fail here
    orders, errors = [], []

    begin
      Order.transaction do
        parser_orders.each do |order|
          begin
            orders << create_order(order)
          rescue OrderAlreadyExistsError => e # if the order already existed, no problem really, just notify
            errors << e
          rescue => e
            errors << e
            orders = [] # clear out the orders array, b/c we're about to roll everything back
            raise AtLeastPartialFailure # raise an error here b/c we dont need to even look at the order orders
          end
        end
        # raise AtLeastPartialFailure if errors.size > 0 # or raise it here?
      end # end the transaction

    rescue AtLeastPartialFailure
      ActiveRecord::Base.logger.warn "got a partial failure when trying to create orders"
      # do nothing, this is just to DB rollback
    end
    [orders, errors]
  end

  def create_order(order)
#    Order.transaction do
      # check for existing order id, raise an exception
      # you really shouldn't implement this until you get the order data. then you just use the validations
      # in that object to test if we can create this object

      new_order = Order.create
      new_order.save

      begin
        create_and_verify_outside_order_attributes(order, new_order)
        create_payment_information(order, new_order)
        create_order_billing_information(order, new_order)
        create_order_ship_to_information(order, new_order)
        create_order_shipping_information(order, new_order)
        create_order_line_items(order, new_order)
        create_order_custom_data(order, new_order)

        new_order.state = order.initial_state if order.initial_state 
      rescue => e
        new_order.destroy
        raise e
      end

      new_order.save
      new_order
#    end
  end

  private

  def create_payment_information(order, new_order)
    # for now, create a creditcard payment, b/c thats all spree supports, but maybe in the future do something better
    # create the cc payment
    # then we can attach an addressable to it
    payment = CreditcardPayment.new(:order_id => new_order.id, :number => "AMAZON_PAYMENT")

    # HACK to override the callback
    payment.instance_eval do
      def authorize
      end
    end

    new_order.creditcard_payment = payment
    payment.save
  end


  # :use_shipping_if_missing_info - use shipping information if we don't have
  # enough billing info (e.g. amazon orders)
  # todo, this could use a big refactoring with the shipping information below
  def create_order_billing_information(order, new_order, opts={})
      opts[:use_shipping_if_missing_info] ||= true # todo, actually use this value

      shipping_country = Country.find_by_iso(order.billing_country || order.shipping_country) || Country.find(Spree::Config[:default_country_id])
      state = State.find_by_name(order.billing_state || order.shipping_state) || State.find_by_abbr(order.billing_state || order.shipping_state)

      # add billing information
      first, last = order.billing_name.split(/ /, 2)
      billing = Address.create(:firstname  => first,
      :lastname                            => last,
      :phone                               => order.billing_phone_number,
      :email                               => order.billing_email,
      :country_id                          => shipping_country.id,
      :address1                            => order.billing_address_one || order.shipping_address_one,
      :address2                            => order.billing_address_two || order.shipping_address_two,
      :city                                => order.billing_city        || order.shipping_city,
      :state_id                            => state.id,
      :zipcode                             => order.billing_zip         || order.shipping_zip)
                               

      # attr_at_xpath :billing_email,         "/BillingData/BuyerEmailAddress"
      # new_order.bill_address = billing
      billing.addressable = new_order.creditcard_payment
      billing.save_without_validation
  end

  def create_order_ship_to_information(order, new_order)
      # add shipping_information
      shipping_country = Country.find_by_iso(order.shipping_country) || Country.find(Spree::Config[:default_country_id])
      # state = State.find_or_create_by_name_and_country_id(order.shipping_state, shipping_country.id) # ... ?
      state = State.find_by_name(order.shipping_state) || State.find_by_abbr(order.shipping_state)
    
      first, last = order.shipping_name.split(/ /, 2)
      shipping = Address.create(:firstname => first, 
                                :lastname => last, 
                                :phone => order.shipping_phone, 
                                :country_id => shipping_country.id,
                                :address1 => order.shipping_address_one,
                                :address2 => order.shipping_address_two,
                                :city => order.shipping_city,
                                :state_id => state.id,
                                :zipcode => order.shipping_zip
                               )
      new_order.address = shipping
      shipping.addressable = new_order # why do i have to do this?
      shipping.save
  end

  def create_order_shipping_information(order, new_order)
    shipping_method = ShippingMethod.find_or_create_by_name(order.fulfillment_level)
    shipping_method.shipping_calculator ||= "Sogi::NullShipping" # todo, for now, punt on figuring this out. ideally read the shipping quantity from the channel
    shipping_method.save
    shipment = Shipment.create(:shipping_method_id => shipping_method.id, :order_id => new_order.id)
    shipment.save
  end

  def create_order_line_items(parser_order, new_order)
    parser_order.line_items.each do |parser_item|
      product = find_or_create_product_for(parser_item)
      variant = Variant.find(:first, :conditions => ["product_id = ? AND sku = ?", product.id, parser_item.sku])

      special_instructions = parser_item.custom_attributes.collect{|k,v| "#{k}: #{v}"}.join(", ")

      line_item = LineItem.create(:variant_id => variant.id,
                                  :quantity => parser_item.quantity,
                                  :price => parser_item.price,
                                  :ship_amount => parser_item.shipping_price,
                                  :tax_amount => parser_item.tax,
                                  :ship_tax_amount => parser_item.shipping_tax,
                                  :special_instructions => special_instructions,
                                  :origin_order_item_identifier => parser_item.order_code)
      new_order.line_items << line_item
    end
  end

  # TODO this will become more meta. you specify what data is going to be
  # custom fields in the PARSER and then define how to get that data. TODO
  # write this to use that
  #
  # for each custom order data specified,
  # if its a Symbol, its a method on the parsed order
  # if it is a String it is considered a literal value
  # if it is a Proc, call that proc with the parsed order
  #
  # write a custom property with that value
  def create_order_custom_data(porder, new_order)
    custom_attrs = porder.class.custom_attributes_and_instructions
    custom_attrs.each do |key,instruction|
      value = case instruction.class.to_s
              when 'String' then instruction
              when 'Symbol' then porder.send(instruction)
              when 'Proc'   then instruction.call(porder)
              else nil
              end
               
      new_order.properties.write key, value
    end
  end

  # does this method belong here? maybe not
  def create_product_for(line_item)
    product = Product.create(:name => line_item.title, 
                             :master_price => line_item.price, 
                             :description => line_item.title)
    product.save!
    product.variants.create(:product_id => product.id, :sku => line_item.sku, :price => line_item.price)
    product
  end

  def find_or_create_product_for(line_item)
    products = Product.by_sku line_item.sku
    if products.size > 0
      return products.first
    else
      return create_product_for(line_item)
    end
  end

  def create_and_verify_outside_order_attributes(porder, new_order)
    ooa = OutsideOrderAttribute.create(
      :origin_channel            => @parser.origin_channel,
      :origin_account_identifier => @parser.merchant_identifier,
      :origin_order_identifier   => porder.order_id,
      :origin_account_short_name => @opts[:origin_account_short_name],
      :origin_account_transaction_identifier => @opts[:origin_account_transaction_identifier],
      :ordered_at                => porder.ordered_at,
      :posted_at                 => porder.posted_at)
    unless ooa.valid?
      raise OrderAlreadyExistsError.new(new_order), 
      "Order origin_id #{porder.order_id} for #{@parser.origin_channel} account #{@parser.merchant_identifier} already exists"
    end
    ooa.order = new_order
    ooa.save
    ooa
  end

end
