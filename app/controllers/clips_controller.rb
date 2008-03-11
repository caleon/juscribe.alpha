# This controller is only accessible within the scope of a widgetable model's
# controller. See routes.rb.
class ClipsController < ApplicationController
  use_shared_options :widget
  
  def index
    return unless get_widgetable(:message => "Unable to find the object specified. Please check the address.")
    find_opts = get_find_opts(:order => 'id DESC')
    @widget = @widgetable.clips.find(:all, find_opts)
    respond_to do |format|
      format.html
      format.xml
    end
  end
  
  def new
    return unless get_widgetable(:message => "Unable to find object to clip. Please check the address.")
    super
  end
  
  def create
    return unless get_widgetable(:message => "Unable to find object to clip. Please check the address.")
    if @widgetable.clip!(:user => get_viewer)
      msg = "You have clipped #{@widgetable.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @widgetable }
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
  
  # TODO: Can the owner of @widgetable unclip it if desired?
  def destroy
    return unless setup
    @widgetable.unclip!(:user => get_viewer)
    msg = "You have unclipped #{@widgetable.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to @widgetable }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  # Overriding default setup method in ApplicationController
  def setup(includes=nil, error_opts={})
    return unless get_widgetable
    @widget = @widgetable.clips.find(params[:id], :include => includes)
    true && authorize(@widget)
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That Clip could not be found. Please check the address."
    display_error(error_opts) # Error will only have access to @object from the setup method.
    false
  end
  
  # Method sets @widgetable based on param keys, or if not found, displays error.
  def get_widgetable(opts={})
    return unless widgetable_id_key = params.keys.detect{|key| key.to_s.match(/_id$/)}
    widgetable_class = widgetable_id_key.to_s.gsub(/_id$/, '').classify.constantize
    @widgetable = widgetable_class.primary_find(params[widgetable_id_key])
  rescue ActiveRecord::RecordNotFound
    display_error(:message => opts[:message] || "That #{widgetable_class} does not have the clip you requested.")
    false
  end
end
