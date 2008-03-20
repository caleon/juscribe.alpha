# This controller is only accessible within the scope of a widgetable model's
# controller. See routes.rb.
class ClipsController < ApplicationController  
  use_shared_options :widget
  verify_login_on :new, :create, :edit, :update, :destroy
  authorize_on :index, :show, :new, :create, :edit, :update, :destroy
  
  def index
    return unless get_widgetable(:message => "Unable to find the object specified. Please check the address.") && authorize(@widgetable)
    find_opts = get_find_opts(:order => 'id DESC')
    @clips = @widgetable.clips.find(:all, find_opts)
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
  end
  
  def show
    return unless setup # Widget does not associate with Permission.
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
  end
  
  def new
    return unless get_widgetable(:message => "Unable to find object to clip. Please check the address.") && authorize(@widgetable)
    @clip = Widget.new
  end
  
  def create
    return unless get_widgetable(:message => "Unable to find object to clip. Please check the address.") && authorize(@widgetable)
    if @clip = @widgetable.clip!(params[:clip].merge(:user => get_viewer)) # TODO: Error messaging for already being clipped.
      msg = "You have clipped #{@widgetable.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to widgetable_url_for(@widgetable) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error clipping #{@widgetable.display_name}. #{@clip.errors.inspect}"
      respond_to do |format|
        format.html { render :action => 'show' }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup && authorize(@clip, :editable => true)
    @page_title = "#{@clip.display_name} - Edit"
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def update
    return unless setup && authorize(@clip, :editable => true)
    if @clip.update_attributes(params[:clip])
      msg = "You have successfully updated #{@clip.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to widgetable_url_for(@widgetable) } # New pattern for polymorphic models
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your #{@clip.display_name}."
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  # TODO: Can the owner of @widgetable unclip it if desired?
  def destroy
    return unless setup && authorize(@clip, :editable => true)
    @widgetable.unclip!(:user => get_viewer)
    msg = "You have unclipped #{@widgetable.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to widgetable_url_for(@widgetable) }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  # Overriding default setup method in ApplicationController
  def setup(includes=nil, error_opts={})
    return unless get_widgetable
    @clip = @widgetable.clips.find(params[:id], :include => includes)
    authorize(@widgetable)
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That Clip could not be found. Please check the address."
    display_error(error_opts) # Error will only have access to @object from the setup method.
    false
  end
  
  def get_widgetable(opts={})
    unless request.path.match(/\/([_a-zA-Z]+)\/([^\/]+)\/clips/)
      display_error(:message => "Unable to process the request. Please check the address.")
      return false
    end
    begin      
      klass, id = $1.singularize.classify.constantize, $2
      @widgetable = klass.primary_find(id, :include => :permission)
    rescue NameError
      klass, id = Article, nil
      @widgetable = Article.primary_find(params, :for_association => true, :include => :permission)
    end
    raise ActiveRecord::RecordNotFound if @widgetable.nil?
    @widgetable
  rescue ActiveRecord::RecordNotFound
    display_error(:message => opts[:message] || "That #{klass.to_s.humanize} could not be found. Please check the address.")
  end
  
  def clip_url_for(clip, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{clip.path_name_prefix}_url(clip.to_path) }
  end
  
  def widgetable_url_for(widgetable, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{widgetable.path_name_prefix}_url(widgetable.to_path) }
  end
end
