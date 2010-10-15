class RemoveOldPriorityAssociations < ActiveRecord::Migration
  def self.up
    
    #turn existing project associated priorities into proper Project priorities
    Priority.find(:all,:conditions => 'project_id is not null').each do |priority|
      priority.update_attributes!(:prioritizable_type => 'Project', :prioritizable_id => priority.project_id)
    end
    
    #Turn personal priorities(authored, no project) into proper User priorities
    Priority.find(:all,:conditions => 'project_id is null').each do |priority|
      priority.update_attributes!(:prioritizable => priority.author)
    end
    
    remove_column :priorities, :project_id

  end

  def self.down
    add_column :priorities, :project_id, :integer

  end
end
