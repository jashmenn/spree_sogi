class AddStateNormalizedField < ActiveRecord::Migration
  def self.up
    add_column(:states, :name_normalized, :string)
  end

  def self.down
    remove_column(:states, :name_normalized)
  end
end
