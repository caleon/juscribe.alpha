class UsersController < ApplicationController
  use_shared_options :custom_finder => :find_by_nick

  verify_login_on :edit, :update, :edit_password, :update_password, :befriend, :unfriend, :logout
  authorize_on :edit, :update, :edit_password, :update_password
      

  def show
    super(:include => :permission) do |marker|
      case marker
      when :after_setup
        @widgets = @user.widgets.placed # TODO: write custom sql for widgetable
        @skin_file = @user.skin_file
        @layout_file = @user.layout_file
      end
    end
  end
  
  def create
    @user = User.new(params[:user])
    @user.nick, @user.email = params[:user][:nick], params[:user][:email]
    if @user.save
      session[:id] = @user.id
      get_viewer
      create_uploaded_picture_for(@user, :save => true) if picture_uploaded?
      msg = "You are now a registered user! Welcome!"
      respond_to do |format|
        format.html do
          flash[:notice] = msg
          redirect_to @user
        end
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an issue with the registration form."
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def update    
    return unless setup
    if @user.update_attributes(params[:user])
      save_uploaded_picture_for(@user) if picture_uploaded?
      msg = "You have successfully updated your profile."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @user }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your profile."
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def edit_password
    return unless setup
    @page_title = "#{@user.nick} - Edit Password"
  end
  
  def update_password
    return unless setup
    if @user.update_attributes(params[:user])
      msg = "You have successfully changed your password."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @user }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an issue with the change password form."
      respond_to do |format|
        format.html { render :action => 'edit_password' }
        format.js { render :action => 'update_password_error' }
      end
    end      
  end
  
  def login
    @page_title = "Login"
    if request.post?
      if (@user = User.find_by_nick(params[:user][:nick])) && @user.authenticate(params[:user][:password])
        session[:id] = @user.id
        msg = "You are now logged in."
        respond_to do |format|
          format.html { flash[:notice] = msg; redirect_to @user }
          format.js { flash.now[:notice] = msg; render :action => 'login_success' }
        end
      else
        flash.now[:warning] = "There was an error logging you in."
        @user ||= User.new
        @user.errors.add(:nick, "is not a user in our database.") unless @user.nick
        respond_to do |format|
          format.html
          format.js { render :action => 'login_error' }
        end
      end
    else
      if session[:id]
        @user = get_viewer
        msg = "You are already logged in."
        respond_to do |format|
          format.html { flash[:notice] = msg; redirect_to @user }
          format.js { flash.now[:notice] = msg; render :action => 'login_already' }
        end
      else
        @user = User.new
      end
    end
  end
  
  def logout
    session[:id] = nil
    reset_session
    msg = "You are now logged out. See you soon!" # Needs to be set after reset_session.
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to @viewer }
      format.js { flash.now[:notice] = msg }
    end
    @viewer = nil
  end
  
  def mine; redirect_to get_viewer || login_url; end
  
  def friends
    return unless setup
    @friends = @user.friends(:include => [ :primary_picture, :permission ])
  end
  
  def befriend
    return unless setup
    if res = get_viewer.befriend(@user) # This sends out notifier in model.
      @notice = [ "You have requested friendship with #{@user.display_name}.",
                  "You are now friends with #{@user.display_name}." ][res]
      respond_to do |format|
        format.html do
          flash[:notice] = @notice
          redirect_to @user
        end
        format.js          
      end
    else
      flash.now[:warning] = "There was an error friending #{@user.display_name}."
      respond_to do |format|
        format.html do
          params[:id] = get_viewer.nick
          show
        end
        format.js { render :action => 'befriend_error' }
      end
    end
  end
  
  def unfriend
    return unless setup
    if get_viewer.kinda_friends_with?(@user) && get_viewer.unfriend(@user)
      msg = "You are no longer friends with #{@user.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to get_viewer }
        format.js { flash.now[:notice] = msg; }
      end
    else
      flash.now[:warning] = "You cannot unfriend #{@user.display_name}."
      respond_to do |format|
        format.html do
          params[:id] = get_viewer.friends_with?(@user) ? @user.nick : get_viewer.nick
          show
        end
        format.js { render :action => 'unfriend_error'}
      end
    end
  end
  
  def about
    return unless setup
  end
end
