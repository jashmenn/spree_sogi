class AddShippedAtTimeForShipments < ActiveRecord::Migration
  def self.up
    add_column(:shipments, :shipped_at, :timestamp)
  end

  def self.down
    remove_column(:shipments, :shipped_at)
  end
end
