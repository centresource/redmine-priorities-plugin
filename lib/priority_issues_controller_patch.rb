# Redmine - project management software
# Copyright (C) 2006-2008  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require_dependency 'issues_controller'

module PriorityIssuesControllerPatch
  module ClassMethods    
    def set_priorities
      @allowed_to_edit_priorities = User.current.allowed_to?(:edit_priorities, @project)
      
      #find all priorities that relate to this issue... but only collect the 'highest' ones, as we dont want to double render. 
      #consider a nested priority list, A -> B -> [C,D]  where B and D both refer to the issue.
      #We only want to show B, the highest related priority.
      
      #get all the issue priorities, highest first.
      all_issue_priorities = @project.priorities.find_all_by_issue_id(@issue.id).sort{|a,b| a.ancestors.length <=> b.ancestors.length}
      
      @priorities = all_issue_priorities.inject(Set.new) do |highest, priority|
        ancestors = Set.new(priority.ancestors)
        if highest.intersection(ancestors).empty?  
          highest.add priority
        end
        highest
      end
      
      @priorities = @priorities.to_a
    end

    private :set_priorities
  end

  def self.included(base) # :nodoc:
    base.send(:include, ClassMethods)
    base.extend(ClassMethods)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      helper :priorities
      before_filter :set_priorities, :only => :show
    end
  end
end
