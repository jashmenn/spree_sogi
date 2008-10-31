class AddSpecialInstructionsToLineItems < ActiveRecord::Migration
  def self.up
    add_column(:line_items, :special_instructions, :text)
  end

  def self.down
    remove_column(:line_items, :special_instructions)
  end
end
