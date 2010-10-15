class AddCompletedAtToPriorities < ActiveRecord::Migration
  def self.up
    add_column :priorities, :completed_at, :datetime
  end

  def self.down
    remove_column :priorities, :completed_at
  end
end
