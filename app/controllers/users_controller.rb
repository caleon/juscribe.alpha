class UsersController < ApplicationController
  use_shared_options :custom_finder => :find_by_nick

  verify_login_on :edit, :update, :edit_password, :update_password, :befriend, :unfriend, :logout
  authorize_on :show, :edit, :update, :destroy, :edit_password, :update_password
      

  def show
    return unless setup([ :permission, :placed_widgets, :comments ])
    @page_title = "#{@user.display_name}"
    @widgets = @user.placed_widgets.sort_by(&:position).inject([]) {|arr, wid| arr[wid.position - 1] = wid; arr }
    # TODO: write custom sql for widgetable
    @comments = @user.comments.find(:all, :limit => 5)
    @skin_file = @user.skin_file
    respond_to do |format|
      format.html { trender }
      format.js
      format.rss { render :layout => false }
    end
  end
  
  def latest_articles
    @user = User.primary_find(params[:user_id], :include => :latest_articles)
    @articles = @user.latest_articles
    @page_title = "Latest Articles by #{@user.display_name}"
    respond_to do |format|
      format.rss { render :layout => false }
    end
  end
  
  # TODO: quit borrowing normal methods from common and set titles for actions  
  def new
    if get_viewer
      msg = "You are already registered! Please log out to create a new account."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to get_viewer }
        format.js { flash.now[:notice] = msg }
      end
      return
    end
    @page_title = "Become a new Juscribe member!"
    @user = User.new
    @blog = Blog.new
    @registration_closed = registration_closed?
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def create
    @user = User.new(params[:user])
    @user.nick, @user.email = params[:user][:nick], params[:user][:email]
    if registration_closed?
      flash.now[:warning] = "We're sorry. Registration is not open right now."
      respond_to do |format|
        format.html { trender :new }
        format.js { render :action => 'create_error' }
      end
      return
    end
    @blog = Blog.new(params[:blog])
    temp_user = User.find(DB[:garbage_id])
    @blog.bloggable, @blog.user = temp_user, temp_user
    if @user.valid? && !(@blog.short_name.blank? || @blog.name.blank?) && @blog.valid?
      @user.save!
      @blog.bloggable, @blog.user = @user, @user
      @blog.save!
      session[:id] = @user.id
      get_viewer
      create_uploaded_picture_for(@user, :save => true) if picture_uploaded?
      msg = "You are now a registered user! Welcome!"
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @user }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an issue with the registration form."
      respond_to do |format|
        format.html { trender :new }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup(:permission) && authorize(@user, :editable => true)
    @page_title = "#{@user.display_name} - Edit"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def update    
    return unless setup && authorize(@user, :editable => true)
    @page_title = "#{@user.display_name} - Edit"
    if @user.update_attributes(params[:user])
      create_uploaded_picture_for(@user, :save => true) if picture_uploaded?
      msg = "You have successfully updated your profile."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @user }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your profile."
      respond_to do |format|
        format.html { trender :edit }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def edit_password
    return unless setup(:permission) && authorize(@user, :editable => true)
    @page_title = "#{@user.display_name} - Edit Password"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def update_password
    return unless setup(:permission) && authorize(@user, :editable => true)
    @page_title = "#{@user.display_name} - Edit Password"
    if @user.update_attributes(params[:user])
      msg = "You have successfully changed your password."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @user }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an issue with the change password form."
      respond_to do |format|
        format.html { trender :edit_password }
        format.js { render :action => 'update_password_error' }
      end
    end      
  end
  
  def destroy
    return unless setup(:permission) && authorize(@user, :editable => true)
    msg = "You have deleted #{flash_name_for(@user)}."
    @user.nullify!(get_viewer)
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to :back }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  def login
    @page_title = "Login"
    if request.post?
      user = User.find_by_nick(params[:user][:nick])
      if user && user.authenticate(params[:user][:password])
        @user = user
        session[:id] = @user.id
        before_login = session[:before_login]
        session[:before_login] = nil
        msg = "You are now logged in."
        respond_to do |format|
          format.html { flash[:notice] = msg; redirect_to before_login || previous_view || @user }
          format.js { flash.now[:notice] = msg; render :action => 'login_success' }
        end
      else
        flash.now[:warning] = "There was an error logging you in."
        @user = User.new
        @user.errors.add(:nick, "is not a user in our database.") unless user && user.nick
        @user.errors.add(:password, user.errors.on(:password)) if user
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
          format.html { flash[:notice] = msg; redirect_to @user || root_url }
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
      format.html { flash[:notice] = msg; redirect_to root_url } # redirecting to previous view is faulty. might be restricted page.
      format.js { flash.now[:notice] = msg }
    end
    @viewer = nil
  end
  
  def mine; redirect_to get_viewer || login_url; end
  
  def friends
    return unless setup
    @friends = @user.friends(:include => [ :primary_picture, :permission ])
    @page_title = "#{@user.display_name}'s Friends"
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def befriend
    return unless setup
    @page_title = get_viewer.display_name
    if res = get_viewer.befriend(@user) # This sends out notifier in model.
      @notice = [ "You have requested friendship with #{flash_name_for(@user)}.",
                  "You are now friends with #{flash_name_for(@user)}." ][res]
      respond_to do |format|
        format.html { flash[:notice] = @notice; redirect_to @user }
        format.js          
      end
    else
      flash.now[:warning] = "There was an error friending #{flash_name_for(@user)}."
      respond_to do |format|
        format.html { params[:id] = get_viewer.nick; show }
        format.js { render :action => 'befriend_error' }
      end
    end
  end
  
  def unfriend
    return unless setup
    if get_viewer.kinda_friends_with?(@user) && get_viewer.unfriend(@user)
      msg = "You are no longer friends with #{flash_name_for(@user)}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to get_viewer }
        format.js { flash.now[:notice] = msg; }
      end
    else
      flash.now[:warning] = "You cannot unfriend #{flash_name_for(@user)}."
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
    @page_title = "About #{@user.display_name}"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
end
