class AddEmailToAddresses < ActiveRecord::Migration
  def self.up
    add_column(:addresses, :email, :string)
  end

  def self.down
    remove_column(:addresses, :email)
  end
end
