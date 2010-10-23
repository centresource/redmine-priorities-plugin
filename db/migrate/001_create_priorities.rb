class CreatePriorities < ActiveRecord::Migration
  def self.up
    #drop_table :priorities
    create_table :priorities do |t|
      t.column :due, :datetime
      # t.column :priority, :int
      t.column :parent_id, :int
      t.column :text, :string
      t.column :author_id, :int
      t.column :assigned_to_id, :int
      t.column :issue_id, :int
      t.column :done, :boolean
      t.column :completed_at, :datetime
      t.column :prioritizable_id, :integer
      t.column :prioritizable_type, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :priorities
  end
end
