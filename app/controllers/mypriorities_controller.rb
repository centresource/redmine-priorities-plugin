#Inherits from the Priorities controller to save repition of all the priority methods.
#Since priorities attach through the prioritizable interface, all you have to do is override
#the parent_object method, which finds/loads the object that the priorities belong to (User/Project/etc).
class MyprioritiesController < PrioritiesController

  before_filter :authorize
  before_filter :set_user

  def index
    #get all the root level priorities belonging to current user
    @personal_priorities = @user.priorities.roots

    #find the roots of any project priority that belongs to or was authored by the user
    #(The root itself may not belong to the user, but we still want to display it!)
    @project_priorities = Priority.project_priorities.for_user(@user.id).collect{|t| t.root}.uniq

    #group the results by project, into a hash keyed on project.
    #this line is so beautiful it nearly made me cry!
    @grouped_project_priorities = Set.new(@project_priorities).classify { |t| t.prioritizable } 

    @new_priority = @user.priorities.new(:author_id => @user.id)
  end

 protected
  def parent_object
    prioritizable = User.current   #you can only ever view your own mypriorities.
    raise ActiveRecord::RecordNotFound, "Priority association not FOUND! " if !prioritizable

    return prioritizable
  end

 private
  #override the usual authentication to something more appropriate for global, personal priorities.
  def authorize
    action = {:controller => params[:controller], :action => params[:action]}
    allowed = User.current.allowed_to?(action, project = nil, options={:global => true})
    allowed ? true : deny_access
  end

  def set_user
    @user = parent_object
  end

end
