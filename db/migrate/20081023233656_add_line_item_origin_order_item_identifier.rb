class AddLineItemOriginOrderItemIdentifier < ActiveRecord::Migration
  def self.up
    add_column(:line_items, :origin_order_item_identifier, :string) # a unique id, often assigned by an origin channel (e.g. amazon), for a specific item in a specific order
  end

  def self.down
    remove_column(:line_items, :origin_order_item_identifier) 
  end
end
