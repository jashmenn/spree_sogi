# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'
$:.unshift File.dirname(__FILE__) + "/lib"
require 'extensions/object.rb'
require 'extensions/activerecord/find_or_do.rb'

class SogiExtension < Spree::Extension
  version "1.0"
  description "Spree Order Gateway Input (SOGI) is a Spree extension to accept orders via a web-service."
  url "http://github.com/jashmenn/spree_sogi/tree/master"

  define_routes do |map|
    map.sogi_orders_create '/sogi/orders/create/:input_order_format.:format', :controller => "order_gateway_input_controller", :action => "create"
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
  end
  
  def deactivate
    # admin.tabs.remove "Sogi"
  end
end
