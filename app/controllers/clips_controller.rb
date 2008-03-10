# This controller is only accessible within the scope of a widgetable model's
# controller. See routes.rb.
class ClipsController < ApplicationController
  set_model_variables :widget
  
  def index
    return unless get_widgetable
    find_opts = get_find_opts(:order => 'id DESC')
    @objects = @widgetable.clips.find(:all, find_opts)
    set_model_instance(@objects)
    respond_to do |format|
      format.html
      format.xml
    end
  end
  
  def new
    # TODO: finish me.
  end
  
  def create
    return unless setup
    if @object.clip!(:user => @viewer)
      msg = "You have clipped #{@object.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @object }
        format.js { flash.now[:notice] = msg; render :action => 'shared/clip' }
      end
    else
      flash.now[:warning] = "There was an error clipping #{@object.display_name}."
      respond_to do |format|
        format.html { render :action => 'show' }
        format.js { render :action => 'shared/clip_error' }
      end
    end
  end
  
  def destroy
    return unless setup
    if @object.clip_for?(@viewer)
      if @object.unclip!(:user => @viewer)
        msg = "You have unclipped #{@object.display_name}."
        respond_to do |format|
          format.html { flash[:notice] = msg; redirect_to @object }
          format.js { flash.now[:notice] = msg; render :action => 'shared/unclip' }
        end
      else
        flash.now[:warning] = "There was an error unclipping #{@object.display_name}."
        respond_to do |format|
          format.html { render :action => 'show' }
          format.js { render :action => 'shared/unclip_error' }
        end
      end
    else
      flash.now[:warning] = "You don't have a clip of #{@object.display_name} to unclip."
      respond_to do |format|
        format.html { render :action => 'show' }
        format.js { render :action => 'shared/unclip_error' }
      end
    end
  end
  
  private
  # Overriding default setup method in ApplicationController
  def setup(includes=nil, error_opts={})
    return unless get_widgetable
    @object = @widgetable.clips.find(params[:id], :include => includes)
    set_model_instance(@object)
    true && authorize(@object)
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That Clip could not be found. Please check the address."
    display_error(error_opts) # Error will only have access to @object from the setup method.
    false
  end
  
  # Method sets @widgetable based on param keys, or if not found, displays error.
  def get_widgetable
    return unless widgetable_id_key = params.keys.detect{|key| key.to_s.match(/_id$/)}
    widgetable_class = widgetable_id_key.to_s.gsub(/_id$/, '').classify.constantize
    @widgetable = widgetable_class.primary_find(params[widgetable_id_key])
  rescue ActiveRecord::RecordNotFound
    display_error(:message => "That #{widgetable_class} does not have the clip you requested.")
  end
end
