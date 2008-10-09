class CreateOutsideOrderAttributes < ActiveRecord::Migration
  def self.up
    create_table :outside_order_attributes do |t|
      t.string :origin_channel
      t.string :origin_account_identifier
      t.string :origin_order_identifier
      t.timestamp :ordered_at
      t.timestamp :posted_at
      t.string :raw_order_file_location
      t.integer :order_id

      t.timestamps
    end
    add_index :outside_order_attributes, :order_id

  end

  def self.down
    drop_table :outside_order_attributes
  end
end
