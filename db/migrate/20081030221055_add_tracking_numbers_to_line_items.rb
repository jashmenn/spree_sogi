class AddTrackingNumbersToLineItems < ActiveRecord::Migration
  def self.up
    add_column(:line_items, :tracking_number, :string)
  end

  def self.down
    remove_column(:line_items, :tracking_number)
  end
end
