# This controller is only accessible within the scope of a widgetable model's
# controller. See routes.rb.
class ClipsController < ApplicationController  
  use_shared_options :widget, :collection_owner => :widgetable, :plural_sym => :clips
  verify_login_on :new, :create, :edit, :update, :destroy
  authorize_on :index, :show, :new, :create, :edit, :update, :destroy
  
  def index
    return unless get_widgetable(:message => "Unable to find the object specified. Please check the address.") && authorize(@widgetable)
    find_opts = get_find_opts(:order => 'id DESC')
    @clips = @widgetable.clips.find(:all, find_opts)
    @page_title = "Clips for #{@widgetable.display_name}"
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def show
    return unless setup # Widget does not associate with Permission.
    @page_title = @clip.display_name
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def new
    return unless get_widgetable(:message => "Unable to find object to clip. Please check the address.") && authorize(@widgetable)
    @clip = Widget.new
    @page_title = "New Clip for #{@widgetable.display_name}"
    respond_to do |format|
      format.html { trender }
      format.js { render :partial => 'new', :content_type => :html }
    end
  end
  
  def create
    return unless get_widgetable(:message => "Unable to find object to clip. Please check the address.") && authorize(@widgetable)
    @page_title = "New Clip for #{@widgetable.display_name}"
    if @clip = @widgetable.clip!((params[:clip] || {}).merge(:user => get_viewer)) # TODO: Error messaging for already being clipped.
      msg = "You have clipped #{flash_name_for(@widgetable)}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to widgetable_url_for(@widgetable) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error clipping #{flash_name_for(@widgetable)}. Do you already have this clipped?"
      respond_to do |format|
        format.html { trender :new }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup && authorize(@clip, :editable => true)
    @page_title = "#{@clip.display_name} - Edit"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def update
    return unless setup && authorize(@clip, :editable => true)
    @page_title = "#{@clip.display_name} - Edit"
    if @clip.update_attributes(params[:clip])
      msg = "You have successfully updated #{flash_name_for(@clip)}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to widgetable_url_for(@widgetable) } # New pattern for polymorphic models
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your #{flash_name_for(@clip)}."
      respond_to do |format|
        format.html { trender :edit }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def destroy
    return unless setup && authorize(@clip, :editable => true)
    @widgetable.unclip!(:user => get_viewer)
    msg = "You have unclipped #{flash_name_for(@widgetable)}."
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
    unless request.path.match(/\/([-_a-zA-Z0-9]+)\/([^\/]+)\/clips/)
      display_error(:message => "Unable to process the request. Please check the address.")
      return false
    end
    begin      
      klass_name = $1.size == 1 ? {'u' => 'users', 'g' => 'groups'}[$1] : $1
      klass, id = klass_name.singularize.classify.constantize, $2
      @widgetable = klass.primary_find(id, :include => :permission_rule)
    rescue NameError
      klass, id = Article, nil
      @widgetable = Article.primary_find(params, :for_association => true, :include => :permission_rule)
    end
    raise ActiveRecord::RecordNotFound if @widgetable.nil?
    @widgetable
  rescue ActiveRecord::RecordNotFound
    display_error(:message => opts[:message] || "That #{klass.to_s.humanize} could not be found. Please check the address.")
  end
end
