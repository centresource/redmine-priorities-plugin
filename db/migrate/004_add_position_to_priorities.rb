class AddPositionToPriorities < ActiveRecord::Migration
  def self.up
    add_column :priorities, :position, :integer
  end

  def self.down
    remove_column :priorities, :position
  end
end
