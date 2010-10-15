class AddPriorityableFields < ActiveRecord::Migration
  def self.up
    add_column :priorities, :prioritizable_id, :integer
    add_column :priorities, :prioritizable_type, :string
  end

  def self.down
    remove_column :priorities, :prioritizable_id
    remove_column :priorities, :prioritizable_type
  end
end
