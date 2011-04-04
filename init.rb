require 'redmine'

# Hooks
require_dependency 'priority_issues_hook'

# Patches to the Redmine core
require 'dispatcher'

Dispatcher.to_prepare do
  require_dependency 'project'
  require_dependency 'user'

  #application.rb changed names between rails verisons - hack for backwards compatibility
  begin
    require_dependency 'application_controller'
  rescue MissingSourceFile
    require_dependency 'application'
  end

  #This file loads some associations into the core redmine classes, like associations to priorities.
  require 'patch_redmine_classes'
  require 'priority_issues_controller_patch'

  # Add module to Project.
  Project.send(:include, PrioritiesProjectPatch)

  # Add module to User, once.
  User.send(:include, PrioritiesUserPatch)

  IssuesController.send(:include, PriorityIssuesControllerPatch)
end

Redmine::Plugin.register :redmine_priorities_plugin do
  name 'Redmine Priorities plugin'
  author 'centresource interactive agency'
  description 'A plugin to create and manage agile-esque priority lists on a per project basis.'
  version '0.0.1'
  

  settings :default => {
    'priorities_auto_complete_parent' => false
  },
  :partial => 'settings/priorities_settings'
  
  project_module :priority_lists do
    permission :view_priorities, {:priorities => [:index, :show] }
      
    permission :edit_priorities,
      { :priorities => [:create, :destroy, :new, :toggle_complete, :sort, :edit, :update],
        :issues => [:create, :destroy, :new, :toggle_complete, :sort, :edit, :update]}
  
    permission :use_personal_priorities,
      { :mypriorities => [:index, :destroy, :new, :create, :toggle_complete, :index, :sort, :edit, :update]}
  end
 
  menu :top_menu, :mypriorities, { :controller => 'mypriorities', :action => 'index' }, 
    :caption => :my_priorities_title,
    :if => Proc.new { User.current.allowed_to?(:use_personal_priorities, nil, :global => true) }
     
  menu :project_menu, :priorities, {:controller => 'priorities', :action => 'index'}, 
      :caption => :label_priority_plural, :after => :new_issue, :param => :project_id

  activity_provider :priorities, :default => false
end

#fix required to make the plugin work in devel mode with rails 2.2
# as per http://www.ruby-forum.com/topic/171629
load_paths.each do |path|
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end
