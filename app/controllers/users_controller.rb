class UsersController < ApplicationController
  before_filter :verify_logged_in, :except => [ :index, :show, :new, :create, :login, :friends, :about ]
  #FIXME: before_filter :only => [:edit, :update, :destroy, :mine] { authenticate(@user) }
  
  verify :method => :post, :only => [ :create ]
  verify :method => :put, :only => [ :update ]
  verify :method => :put, :only => :update_password
  
  def index
    limit, page = 10, params[:page].to_i + 1
    offset = params[:page].to_i * limit
    @users = User.find(:all, :limit => limit, :offset => offset, :order => 'id DESC')
    respond_to do |format|
      format.html
      format.xml
    end
  end
      
  def show
    return unless setup
    @widgets = @user.widgets # TODO: including :widgetable not allowed. write sql.
    @skin_file = @user.skin_file
    @layout = @user.layout
    respond_to do |format|
      format.html
      format.xml # Feed for user comment thread
    end
  end
  
  def new
    @page_title = "Registration"
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.nick, @user.email = params[:user][:nick], params[:user][:email]
    if @user.save
      session[:user_id] = @user.id
      msg = "You are now a registered user! Welcome!"
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @user }
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
  
  def edit
    return unless (setup && @user.editable_by?(@viewer))      
    @page_title = "#{@user.nick} - Edit"
  end
  
  def update
    return unless (setup && @user.editable_by?(@viewer))
    if @user.update_attributes(params[:user])
      msg = "You have successfully edited #{@user.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @user }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an issue with the update form."
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def edit_password
    return unless (setup && @user.editable_by?(@viewer))
    @page_title = "#{@user.nick} - Edit Password"
  end
  
  def update_password
    return unless (setup && @user.editable_by?(@viewer))
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
  
  def destroy
    return unless setup
    if @user.editable_by?(@viewer)
      # Set to disabled user if !admin?
      # Delete if admin?
      msg = "You have deleted #{@user.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to :back }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "You are not allowed to delete #{@user.display_name}."
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js { render :action => 'destroy_error' }
      end
    end
  end
  
  def login # login and logout actions only responds to html
    @page_title = "Login"
    if request.post?
      if (@user = User.find_by_nick(params[:user][:nick])) && @user.authenticate(params[:user][:password])
        session[:user_id] = @user.id
        flash[:notice] = "You are now logged in."
        redirect_to @user
      else
        @user ||= User.new
        @user.errors.add(:nick, "is not a user in our database.") unless @user.nick
      end
    else
      if session[:user_id]
        user = User.find(session[:user_id])
        flash[:notice] = "You are already logged in."
        redirect_to user
      else
        @user = User.new
      end
    end
  end
  
  def logout
    redirect_to user_url(User.find(session[:user_id]))
    session[:user_id] = nil
    reset_session
    flash[:notice] = "You are now logged out. See you soon!"
  end
  
  def mine
    user = User.find(session[:user_id])
    redirect_to User.find(session[:user_id])
  end
  
  def friends
    return unless setup
    @friends = @user.friends(:include => :primary_picture)
  end
  
  def befriend
    return unless setup
    if res = @viewer.befriend(@user) # This sends out notifier.
      @notice = [ "You have requested friendship with #{@user}.",
                  "You are now friends with #{@user}." ][res]
      respond_to do |format|
        format.html do
          flash[:notice] = @notice
          redirect_to @user
        end
        format.js          
      end
    else
      flash.now[:warning] = "There wasn an error friending #{@user.display_name}."
      respond_to do |format|
        format.html do
          params[:id] = @viewer.nick
          show
          render :action => 'show'
        end
        format.js { render :action => 'befriend_error' }
      end
    end
  end
  
  def unfriend
    return unless setup
    if @viewer.kinda_friends_with?(@user) && @viewer.unfriend(@user)
      msg = "You are no longer friends with #{@user.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @viewer }
        format.js { flash.now[:notice] = msg; }
      end
    else
      flash.now[:warning] = "You cannot unfriend #{@user.display_name}."
      respond_to do |format|
        format.html do
          params[:id] = @viewer.friends_with?(@user) ? @user.nick : @viewer.nick
          show
          render :action => 'show'
        end
        format.js { render :action => 'unfriend_error'}
      end
    end
  end
  
  def mailbox
    # FIXME: The following includes array makes it draw ALL associated messages.
    return unless setup([{ :messages => { :sender => :primary_picture } },
                         { :sent_messages => { :recipient => :primary_picture } },
                         { :drafts => {:recipient => :primary_picture } }])
    @messages = @viewer.messages.find(:all, :include => {:sender => :primary_picture}, :limit => 20)
    @sent_messages = @viewer.sent_messages.find(:all, :include => {:recipient => :primary_picture}, :limit => 20)
    @drafts = @viewer.drafts.find(:all, :include => {:recipient => :primary_picture}, :limit => 20)
  end
  
  def about
    return unless setup
  end
  
  private
  def setup(includes=nil, opts={})
    if params[:id] && @user = User.find_by_nick(params[:id], :include => includes)
      true
    else
      display_error(opts)
      false
    end
  end
end
