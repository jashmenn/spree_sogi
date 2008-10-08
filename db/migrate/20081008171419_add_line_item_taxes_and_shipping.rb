class AddLineItemTaxesAndShipping < ActiveRecord::Migration
  def self.up
    add_column(:line_items, :ship_amount, :decimal, :precision => 8, :scale => 2, :default => 0.0, :null => true)
    add_column(:line_items, :tax_amount, :decimal, :precision => 8, :scale => 2, :default => 0.0, :null => true)
    add_column(:line_items, :ship_tax_amount, :decimal, :precision => 8, :scale => 2, :default => 0.0, :null => true)
  end

  def self.down
    remove_column(:line_items, :ship_tax_amount)
    remove_column(:line_items, :tax_amount)
    remove_column(:line_items, :ship_amount)
  end
end
