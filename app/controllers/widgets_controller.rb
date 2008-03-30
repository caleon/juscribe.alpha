class WidgetsController < ApplicationController
  use_shared_options :collection_owner => :user
  verify_login_on :new, :create, :edit, :update, :destroy, :place, :unplace
  authorize_on :index, :show, :edit, :update, :destroy, :place, :unplace

  def index
    return unless get_user(:message => "Unable to find the user specified. Please check the address.") && authorize(@user)
    find_opts = get_find_opts(:order => 'id DESC')
    @widgets = @user.widgets.find(:all, find_opts)
    @page_title = "Customize Widgets"
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def show
    return unless setup
    @page_title = @widget.display_name
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def new
    # This should not be an accessible method.
  end
  
  def create
    # This should not be an accessible method.
  end
  
  def edit
    return unless setup && authorize(@widget, :editable => true)
    @page_title = "#{@widget.display_name} - Edit"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def update
    return unless setup && authorize(@widget, :editable => true)
    @page_title = "#{@widget.display_name} - Edit"
    if @widget.update_attributes(params[:widget])
      msg = "You have successfully updated #{@widget.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to user_widgets_url(@user) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your #{@widget.display_name}."
      respond_to do |format|
        format.html { trender :edit }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def destroy
    return unless setup && authorize(@widget, :editable => true)
    @widget.nullify!(get_viewer)
    msg = "You have deleted #{@widget.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to user_url(@user) }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  def place
    return unless setup && authorize(@widget, :editable => true)
    @widget.place!(params[:widget][:position])
    msg = "You have placed #{@widget.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to user_widgets_url(@user) }
      format.js { flash.now[:notice] = msg }
    end
  rescue
    display_error(:message => "Invalid request. Please try again.")
  end
  
  def unplace
    return unless setup && authorize(@widget, :editable => true)
    @widget.unplace!
    msg = "You have unplaced #{@widget.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to user_widgets_url(@user) }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  def setup(includes=nil, error_opts={})
    return false unless get_user
    @widget = @user.widgets.find(params[:id], :include => includes)
    authorize(@widget)
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That User/Widget could not be found. Please check the URL."
    display_error(error_opts)
    false
  end
end
