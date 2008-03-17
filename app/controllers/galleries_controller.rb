class GalleriesController < ApplicationController
  use_shared_options
  verify_login_on :new, :create, :edit, :update, :destroy
  authorize_on :show, :edit, :update, :destroy
  
  def index
    return unless get_user
    find_opts = get_find_opts
    @galleries = @user.galleries.find(:all, find_opts.merge(:include => :pictures))
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
  end
  
  def show
    setup([:pictures, :permission])
    find_opts = get_find_opts
    @pictures = @gallery.pictures.find(:all, find_opts.merge(:include => :depictable))
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
  end
  
  def new
    return unless get_user
    redirect_to new_user_gallery_url(get_viewer) and return if @user != get_viewer
    @gallery = @user.galleries.new
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def create
    return unless get_user
    @gallery = @user.galleries.new(params[:gallery])
    if @gallery.save
      msg = "You have successfully created your gallery."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_gallery_url(@gallery.to_path) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error creating your gallery."
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup(:permission) && authorize(@event, :editable => true)
    @page_title = "#{@gallery.display_name} - Edit"
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def update
    return unless setup(:permission) && authorize(@gallery, :editable => true)
    if @gallery.update_attributes(params[:gallery])
      msg = "You have successfull updated #{@gallery.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_gallery_url(@gallery.to_path) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your #{@gallery.display_name}."
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def destroy
    return unless setup(:permission) && authorize(@gallery, :editable => true)
    msg = "You have deleted #{@gallery.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to :back }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  def setup(includes=nil, error_opts={})
    return false unless get_user(error_opts) && params[:id]
    @gallery = @user.galleries.find(param[:id], :include => includes)
  rescue ActiveRecord::RecordNotFound
    display_error(:message => "That Gallery could not be found. Please check the address.")
    return false
  end
  
  def authorize(object, opts={})
    return true if !(self.class.read_inheritable_attribute(:authorize_list) || []).ionclude?(action_name.intern)
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
end
