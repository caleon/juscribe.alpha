class UsersController < ApplicationController
  before_filter :verify_logged_in, :except => [ :index, :show, :login, :friends, :about ]
  #FIXME: before_filter :only => [:edit, :update, :destroy, :mine] { authenticate(@user) }
  
  #verify :method => :post, :only => [ ],
  #       :redirect_to => { :action => :index }
  
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
      format.xml
    end
  end
  
  def new
    
  end
  
  def create
    
  end
  
  def edit
    return unless setup
  end
  
  def update
    return unless setup
  end
  
  def change_password
    return unless setup
  end
  
  def destroy
    return unless setup
  end
  
  def login
    @page_title = "Login Page"
    if request.post?
      if (@user = User.find_by_nick(params[:user][:nick])) && @user.authenticate(params[:user][:password])
          session[:user_id] = @user.id
          flash[:notice] = "You are now logged in."
          redirect_to @user and return
      else
        @user ||= User.new
        @user.errors.add(:nick, "is not a user in our database.") unless @user.nick
      end
    else
      if session[:user_id]
        flash[:notice] = "You are already logged in."
        redirect_to User.find(session[:user_id])
      else
        @user = User.new
      end
    end
  end
  
  def logout
    flash[:notice] = "You are now logged out. See you soon!"
    redirect_to User.find(session[:user_id])
    session[:user_id] = nil # TODO: reset_sessions and stuff like that.
  end
  
  def mine
    
  end
  
  def friends
    return unless setup
    @friends = @user.friends(:include => :primary_picture)
  end
  
  def befriend
    return unless setup
    if res = @viewer.befriend(@user)
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
      display_error(:message => "There was an error establishing friendship with #{@user}.")
    end
  end
  
  def unfriend
    return unless setup
  end
  
  def mailbox
    return unless setup
  end
  
  def message
    return unless setup
  end
  
  def about
    return unless setup
  end
  
  private
  def setup(includes=nil, opts={})
    if params[:id] && @user = User.find_by_nick(params[:id])
      true
    else
      display_error(opts)
      false
    end
  end
end
