#custom routes for this plugin

map.resources :priorities, :name_prefix => 'project_', :path_prefix => '/projects/:project_id', :member => {:toggle_complete => :post}, :collection => {:sort => :post}

map.with_options :controller => 'mypriorities' do |r|
  r.new_personal_priority 'mypriorities/:parent_id/new', :action => 'new'
  r.connect 'mypriorities/:parent_id/new.:format', :action => 'new'
end
