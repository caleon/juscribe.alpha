class GalleriesController < ApplicationController
  use_shared_options :collection_owner => :user
  verify_login_on :new, :create, :edit, :update, :destroy
  authorize_on :show, :edit, :update, :destroy
  
  def index
    return unless get_user
    find_opts = get_find_opts
    @galleries = @user.galleries.find(:all, find_opts.merge(:include => :primary_picture))
    @page_title = "#{@user.display_name}'s Galleries"
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def show
    return unless setup([:pictures, :permission])
    find_opts = get_find_opts
    @pictures = @gallery.pictures.find(:all, find_opts)
    @page_title = @gallery.display_name
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def new
    return unless get_user
    redirect_to new_user_gallery_url(get_viewer) and return if @user != get_viewer
    @gallery = @user.galleries.new
    @page_title = "New Gallery for #{@user.display_name}"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def create
    return unless get_user
    @gallery = get_viewer.galleries.new(params[:gallery])
    @page_title = "New Gallery for #{@user.display_name}"
    if @gallery.save
      msg = "You have successfully created your gallery."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_gallery_url(@gallery.to_path) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error creating your gallery."
      respond_to do |format|
        format.html { trender :new }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup(:permission) && authorize(@gallery, :editable => true)
    @page_title = "#{@gallery.display_name} - Edit"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def update
    return unless setup(:permission) && authorize(@gallery, :editable => true)
    @page_title = "#{@gallery.display_name} - Edit"
    if @gallery.update_attributes(params[:gallery])
      msg = "You have successfully updated #{flash_name_for(@gallery)}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_gallery_url(@gallery.to_path) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your #{flash_name_for(@gallery)}."
      respond_to do |format|
        format.html { trender :edit }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def destroy
    return unless setup(:permission) && authorize(@gallery, :editable => true)
    msg = "You have deleted #{flash_name_for(@gallery)}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to :back }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  def setup(includes=nil, error_opts={})
    return false unless get_user(error_opts)
    @gallery = @user.galleries.find(params[:id], :include => includes)
    authorize(@gallery)
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That Gallery could not be found. Please check the address."
    display_error(error_opts)
    return false
  end
end
