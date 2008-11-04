class AddShipmentCarrier < ActiveRecord::Migration
  def self.up
    add_column(:shipments, :carrier_name, :string)
  end

  def self.down
    remove_column(:shipments, :carrier_name)
  end
end
