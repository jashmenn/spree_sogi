# Represents data that is created when an order is created outside of spree and
# entered by some other means
class OutsideOrderAttribute < ActiveRecord::Base
  belongs_to :order
  validates_uniqueness_of :origin_order_identifier, :scope => [:origin_channel, :origin_account_identifier]
end
