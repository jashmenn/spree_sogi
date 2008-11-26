# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'
$:.unshift File.dirname(__FILE__) + "/lib"
require 'extensions/object.rb'
require 'extensions/activerecord/find_or_do.rb'

# If you want to handle errors with a custom function, define the following in config/environment.rb
#
#   SogiExtension.class_eval do
#     def on_importing_error(order)
#       puts order
#     end
#   end
class SogiExtension < Spree::Extension
  version "1.0"
  description "Spree Order Gateway Input (SOGI) is a Spree extension to accept orders via a web-service."
  url "http://github.com/jashmenn/spree_sogi/tree/master"

  define_routes do |map|
    map.sogi_orders_create '/sogi/orders/create/:input_order_format.:format', :controller => "order_gateway_input", :action => "create"
  end

  # TODO define this callback if no-one else has, the below code doesn't work
  # and overrides config/environment.rb however we've got to have a callback
  # here. for now, if anyone doesn't define this they'll get a diff error that
  # this method is undefined
  # 
  # SORRY! HACK HACK. AmazonOrderMailer will NOT exist for everyone. However I
  # have to get this done. Someone please submit a patch for good callbacks in
  # this case.
  unless self.respond_to?(:on_importing_error)
    def self.on_importing_error(subject, message=nil)
      ActiveRecord::Base.logger.fatal "There was a serious problem importing. You'd better check it out: #{subject} #{message}"
      AmazonOrdersMailer.deliver_error(subject, message)
    end
  end

  def activate
    # admin.tabs.add "Sogi", "/admin/sogi", :after => "Layouts", :visibility => [:all]

    Product.class_eval do
      named_scope :for_sku, lambda {|sku| { :include => :variants, :conditions => ["variants.sku = ?", "#{sku}"]}} # exact match for sku finder
    end

    LineItem.class_eval do
      def sku
        return nil unless variant
        return nil unless s = variant.sku
        return s
      end
    end

    Order.class_eval do
      has_one :outside_order_attribute, :dependent => :destroy

      # TODO these methods will be moved into a new object instead of being
      # referenced from custom properties.  inspecting the custom properties
      # themselves outside of this function is done at your own risk as this
      # implementation will change, but the interface will not

      %w{origin_channel origin_account_identifier origin_order_identifier origin_account_short_name origin_account_transaction_identifier}.each do |name|
        define_method name do
          return nil unless self.outside_order_attribute
          self.outside_order_attribute.send(name)
          # properties.read_value(name)
        end
      end

      %w{ordered_at posted_at}.each do |name|
        define_method name do
          # TODO make this return a Time object
          return nil unless self.outside_order_attribute
          self.outside_order_attribute.send(name)
          # properties.read_value(name)
        end
      end
    end

    Product.class_eval do
      named_scope :by_exact_sku, lambda {|sku| { :include => :variants, :conditions => ["variants.sku = ?", sku]}}
    end

    State.class_eval do
      def normalized_name
        name.gsub(/\W/, '').downcase
      end

      def normalize_name!
        self.name_normalized = normalized_name
        self.save
      end
    end

  end
  
  def deactivate
    # admin.tabs.remove "Sogi"
  end
end
