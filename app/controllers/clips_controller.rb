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
    if @clip = @widgetable.clip!(params[:widget].merge(:user => get_viewer)) # TODO: Error messaging for already being clipped.
      msg = "You have clipped #{@widgetable.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to widgetable_url_for(@widgetable) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error clipping #{@widgetable.display_name}."
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
  
  # Method sets @widgetable based on param keys, or if not found, displays error.
  def get_widgetable(opts={})
    return false if (possible_widgetable_id_keys = params.keys.select{|key| key.match(/_id$/)}).empty?
    widgetable_id_key = %w( picture article song project item group event entry list playlist user ).map{|kls| "#{kls}_id"}.detect do |key|
      possible_widgetable_id_keys.include?(key)
    end
    widgetable_class = widgetable_id_key.gsub(/_id$/, '').classify.constantize
    if widgetable_class == Article
      @widgetable = Article.primary_find(params, :for_association => true, :include => :permission )
    else
      @widgetable = widgetable_class.primary_find(params[widgetable_id_key], :include => :permission)
    end
    raise ActiveRecord::RecordNotFound if @widgetable.nil?
    @widgetable
  rescue ActiveRecord::RecordNotFound
    display_error(:message => opts[:message] || "That #{widgetable_class} could not be found.")
    false
  end
  
  #def get_widgetable(opts={})
  #  unless request.path.match(/\/([a-zA-Z]+)\/([^\/]+)\/clips/)
  #    display_error(:message => "Unable to process the request. Please check the address.")
  #    return false
  #  end
  #  begin
  #    klass, id = $1.singularize.classify.constantize, $2
  #    @widgetable = klass.primary_find(id, :include => :permission)
  #  rescue NameError
  #    klass, id = Article, nil
  #    @widgetable = Article.primary_find(params, :for_association => true, :include => :permission)
  #  end
  #  raise ActiveRecord::RecordNotFound if @widgetable.nil?
  #rescue ActiveRecord::RecordNotFound
  #  display_error(:message => opts[:message] || "That #{klass.to_s.humanize} could not be found.")
  #end
  
  def authorize(object, opts={})
    return true if !opts[:manual] && !(self.class.read_inheritable_attribute(:authorize_list) || []).include?(action_name.intern)
    unless object && object.accessible_by?(get_viewer) && (!opts[:editable] || object.editable_by?(get_viewer))
      msg = "You are not authorized for that action."
      respond_to_without_type_registration do |format|
        format.html { flash[:warning] = msg; redirect_to get_viewer || login_url }
        format.js { flash.now[:warning] = msg; render :action => 'shared/unauthorized' }
      end
      return false
    end
    true
  end
  
  def clip_url_for(clip)
    prefix = clip.widgetable_type.underscore
    instance_eval %{ #{prefix}_clip_url(clip.to_polypath) }
  end
  
  def widgetable_url_for(widgetable)
    prefix = widgetable.class.to_s.underscore
    instance_eval %{ #{prefix}_url(widgetable.to_path) }
  end
end
