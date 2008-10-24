class AddOutsideOrderAttributesAccountAndTransactionId < ActiveRecord::Migration
  def self.up
    add_column(:outside_order_attributes, :origin_account_short_name, :string)     # so we know our name for what account this order came from
    add_column(:outside_order_attributes, :origin_account_transaction_identifier, :string) # so we know how to confirm this order
  end

  def self.down
    remove_column(:outside_order_attributes, :origin_account_transaction_identifier) # so we know how to confirm this order
    remove_column(:outside_order_attributes, :origin_account_short_name) # so we know our name for what account this order came from
  end
end
