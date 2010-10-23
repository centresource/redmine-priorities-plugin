class AddPositionToPriorities < ActiveRecord::Migration
  def self.up
    add_column :priorities, :position, :integer, :default => 0
  end

  def self.down
    remove_column :priorities, :position
  end
end
