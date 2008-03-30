class ThoughtletsController < ApplicationController
  use_shared_options :collection_owner => :user
  verify_login_on :new, :create, :edit, :update, :destroy
  authorize_on :show, :edit, :update, :destroy
  
  def index
    return unless get_user
    find_opts = get_find_opts(:order => 'id DESC')
    @thoughtlets = @user.thoughtlets.find(:all, find_opts)
    @page_title = "#{@user.display_name}'s Thoughtlets"
    respond_to do |format|
      format.html { trender }
      format.js
      format.rss { render :layout => false }
    end
  end
  
  def show
    return unless setup(:permission)
    @page_title = @thoughtlet.display_name
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def new
    return unless get_user
    redirect_to new_user_thoughtlet_url(get_viewer) and return if @user != get_viewer
    @thoughtlet = @user.thoughtlets.new
    @page_title = "New Thoughtlet"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def create
    return unless get_user
    @thoughtlet = get_viewer.thoughtlets.new(params[:thoughtlet])
    if @thoughtlet.save
      create_uploaded_picture_for(@thoughtlet, :save => true) if picture_uploaded?
      msg = "You have successfully created your Thoughtlet."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_thoughtlet_url(@thoughtlet.to_path) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error creating your Thoughtlet."
      respond_to do |format|
        format.html { trender :new }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup(:permission) && authorize(@thoughtlet, :editable => true)
    @page_title = "#{@thoughtlet.display_name} - Edit"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def update
    return unless setup(:permission) && authorize(@thoughtlet, :editable => true)
    @page_title = "#{@thoughtlet.display_name} - Edit"
    if @thoughtlet.update_attributes(params[:thoughtlet])
      msg = "You have successfully updated #{@thoughtlet.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_thoughtlet_url(@thoughtlet.to_path) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your #{@thoughtlet.display_name}."
      respond_to do |format|
        format.html { trender :edit }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def destroy
    return unless setup(:permission) && authorize(@thoughtlet, :editable => true)
    msg = "You have deleted #{@thoughtlet.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to :back }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  def setup(includes=nil, error_opts={})
    return false unless get_user
    @thoughtlet = @user.thoughtlets.find(params[:id], :include => includes)
    authorize(@thoughtlet)
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That Thoughtlet could not be found. Please check the address."
    display_error(error_opts)
    false
  end
end
