class NormalizeAllStateNames < ActiveRecord::Migration
  def self.up
    State.find(:all, :conditions => "name_normalized IS NULL").each do |state|
      say "Normalizing #{state.name} to #{state.normalized_name}"
      state.normalize_name!
    end
  end

  def self.down
  end
end
