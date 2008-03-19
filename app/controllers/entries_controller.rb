class EntriesController < ApplicationController
  use_shared_options
  verify_login_on :new, :create, :edit, :update, :destroy
  authorize_on :show, :edit, :update, :destroy
  
  def index
    find_opts = get_find_opts(:order => 'id DESC')
    if @user = User.primary_find(params[:user_id])
      @entries = @user.entries.find(:all, find_opts)
    else
      display_error(:message => "That User entry could not be found. Please check the address.")
    end
  end
  
  def show
    super(:include => :permission)
  end
  
  def new
    return unless get_user
    if @user == get_viewer
      @entry = @user.entries.new
    else
      redirect_to new_user_entry_url(get_viewer) and return
    end
  end
  
  def create
    return unless get_user
    @entry = get_viewer.entries.new(params[:entry])
    if @entry.save
      create_uploaded_picture_for(@entry, :save => true) if picture_uploaded?
      msg = "You have successfully created your Entry."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_entry_url(@entry.to_path) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error creating your Entry."
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup(:permission) && authorize(@entry, :editable => true)
    @page_title = "#{@entry.display_name} - Edit"
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def update
    return unless setup(:permission) && authorize(@entry, :editable => true)
    if @entry.update_attributes(params[:entry])
      msg = "You have successfully updated #{@entry.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_entry_url(@entry.to_path) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your #{@entry.display_name}."
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def destroy
    return unless setup(:permission) && authorize(@entry, :editable => true)
    msg = "You have deleted #{@entry.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to :back }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  def setup(includes=nil, error_opts={})
    return false unless get_user
    @entry = @user.entries.find(params[:id], :include => includes)
    authorize(@entry)
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That Entry could not be found. Please check the address."
    display_error(error_opts)
    false
  end
end
