# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'

class SogiExtension < Spree::Extension
  version "1.0"
  description "Spree Order Gateway Input (SOGI) is a Spree extension to accept orders via a web-service."
  url "http://github.com/jashmenn/spree_sogi/tree/master"

  # define_routes do |map|
  #   map.namespace :sogi do |sogi|
  #     sogi.create :create

  # map.signup '/signup', :controller => 'users', :action => 'new'
  #   end  
  # end
  # map.connect 'accounts/:action/:login',
  #      :controller => 'accounts'

  # map.connect 'stores/:action/:short_name',
  #      :controller => 'stores',
  #      :requirements => { :short_name => /[^\d]/ }
  
  def activate
    # admin.tabs.add "Sogi", "/admin/sogi", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Sogi"
  end
  
end
