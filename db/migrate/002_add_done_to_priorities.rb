class AddDoneToPriorities < ActiveRecord::Migration
  def self.up
    add_column :priorities, :done, :boolean
  end

  def self.down
    remove_column :priorities, :done
  end
end
