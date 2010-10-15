#custom routes for this plugin
ActionController::Routing::Routes.draw do |map|

  map.resources :priorities, :name_prefix => 'project_', :path_prefix => '/projects/:project_id',
    :member => {:toggle_complete => :post }, :collection => {:sort => :post}

  map.resources :priorities, :name_prefix => 'user_', :path_prefix => '/users/:user_id', :controller => :mypriorities,
    :member => {:toggle_complete => :post }, :collection => {:sort => :post}

  #nicer looking shortcut to mypriorities for the top menu
  map.my_priorities 'my/priorities', :controller => :mypriorities, :action => :index

end
