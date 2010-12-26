class PrioritiesController < ApplicationController
  
  before_filter :find_priority, :only => [:destroy, :show, :toggle_complete, :edit, :update]
  before_filter :authorize

  helper :priorities
  
  # global string to use as the suffix for the element id for priority's <UL> 
  UL_ID = "priority-children-ul_"
  PRIORITY_LI_ID = "priority_"
  
  def index
    find_project
    @priorities = @project.priorities.roots

    # filter by user_id
    if params[:user_id] && params[:user_id] != '0'
      @priorities = @priorities.reject { |p| p.assigned_to_id.to_s != params[:user_id] }
    end

    @allowed_to_edit = User.current.allowed_to?(:edit_priorities, @project)

    @new_priority = parent_object.priorities.new()

    @member_choices = @project.members.collect { |member| [member.name, member.user_id] }.unshift(['All Users', 0])
  end

  def destroy
    if @priority.destroy
      flash[:priority] = l(:notice_successful_delete) unless request.xhr?
    else
      flash[:error] = l(:notice_unsuccessful_save) unless request.xhr?
    end
    render :text => @priority.errors.collect{|k,m| m}.join
  end

  def show    
    respond_to do |format|
      format.html { render }
      format.js { 
        @element_html = render_to_string :partial => 'priorities/priority',
                                         :locals => {:priority => @priority, :editable => true}                 
        render :template => "priorities/priority.rjs"
      }
    end
  end

  def new
    @priority = parent_object.priorities.new
    @priority.parent_id = parent_object.priorities.find(params[:parent_id]).id
    @priority.refers_to = Issue.find(params[:issue_id]) if params[:issue_id]
    
    render :partial => 'new_priority', :locals => { :priority => @priority}
  end
  
  def toggle_complete
    @priority.set_done !@priority.done
    if (request.xhr?)
      @element_html = render_to_string :partial => 'priorities/priority', :locals => {:priority => @priority, :editable => true}
      render :template => "priorities/priority.rjs"
    else
      redirect_to :action => "index", :project_id => params[:project_id]
    end
  end

  def create
    @priority = parent_object.priorities.new(params[:priority])
    @priority.author = User.current

    respond_to do |format|
      # first, make sure the issue has an owner if this is an issue priority
      if !@priority.issue_id.nil?
        issue = Issue.find(@priority.issue_id)
        if issue.assigned_to_id.nil?
          message = "Selected issue must be assigned before it can be used for a priority.  Click <a href=\"/issues/#{@priority.issue_id}\">here</a> to assign";
          format.html {
            flash[:error] = message
            redirect_to(:action => "index", :project_id => params[:project_id]) and return
          }
          format.js {
            render :update do |page|
              page.replace_html 'priority-error', "<p>#{message}</p>"
            end and return
          }
        else
          @priority.assigned_to_id = issue.assigned_to_id
        end
      end
      
      if @priority.save
        format.html {
          flash[:notice] = l(:notice_successful_create)
          redirect_to(:action => "index", :project_id => params[:project_id]) and return
        }
        format.js {
          @element_html = render_to_string :partial => 'priorities/priority_li', :locals => { :priority => @priority, :editable => true }
          render :template => "priorities/create.rjs" and return   #using rjs
        }
      else
        format.html {
          flash[:notice] = "Priority could not be created."
          redirect_to(:action => "index", :project_id => params[:project_id]) and return
        }
        format.js {
          render :update do |page|
            page.replace_html 'priority-error', '<p>There was an error saving the priority. Make sure to provide all required fields.</p>'
          end and return
        }
      end
    end
  end
  
  #for the d&d sorting ajax helpers
  #TODO: this is pretty messy.
  def sort
    raise l(:priority_sort_no_project_error) if !parent_object
    
    @priorities = parent_object.priorities
    
    params.keys.select{|k| k.include? UL_ID }.each do |key|
      Priority.sort_priorities(@priorities, params[key])
    end
    
    render :nothing => true
  end

  def update
    if @priority.update_attributes(params[:priority])
      if request.xhr?
        show
      else
        flash[:notice] = "Priority updated!"
        redirect_to :action => :index
      end
    else
      render :text => "Error in update"
    end
  end

  def edit
    if request.xhr?
      respond_to do |format|
        format.html { render :partial => "priorities/inline_edit", :locals => {:priority => @priority} }
      end
    else
      raise "Non-ajax editing not supported..."
    end
  end

 protected
  #TODO: there may be a better way...
  def parent_object
    prioritizable = Project.find(params[:project_id]) if params[:project_id]
    raise ActiveRecord::RecordNotFound, "Priority association not FOUND! " if !prioritizable
    
    return prioritizable
  end
  
  def find_priority
    @priority = parent_object.priorities.find(params[:id])
    raise ActiveRecord::RecordNotFound, "PRIORITY NOT FOUND! id:" + params[:id] unless @priority
  end
  
 private
  def find_project
    @project = Project.find(params[:project_id])
    raise ActiveRecord::RecordNotFound, l(:priority_project_not_found_error) + " id:" + params[:project_id] unless @project
  end
  
  def authorize
    find_project
    super
  end
end
