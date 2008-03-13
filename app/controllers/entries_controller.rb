class EntriesController < ApplicationController
  use_shared_options
  verify_login_on :new, :create, :edit, :update, :destroy
  authorize_on :show, :edit, :update, :destroy
  
  def create
    @entry = Entry.new(params[:entry].merge(:user => get_viewer))
    if @entry.save
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
  
  private
  def setup(includes=nil, error_opts={})
    if @user = User.find_by_nick(params[:user_id])
      if @entry = Entry.find(params[:id], :conditions => ["user_id = ?", @user.id], :include => includes)
        true && authorize(@entry)
      else
        error_opts[:message] ||= "That Entry could not be found. Please check the address."
        display_error(error_opts)
        false
      end
    else
      error_opts[:message] ||= "That User entry could not be found. Please check the address."
      display_error(error_opts)
      false
    end
  end
  
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
end
