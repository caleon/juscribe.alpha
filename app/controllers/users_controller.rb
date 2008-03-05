class UsersController < ApplicationController
  before_filter :verify_logged_in, :except => [ :index, :show, :new, :create, :login, :friends, :about ]
  #FIXME: before_filter :only => [:edit, :update, :destroy, :mine] { authenticate(@user) }
  
  verify :method => :post, :only => [ :create ],
         :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :edit ],
         :redirect_to => @user
  
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
    @page_title = "Registration Page"
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.nick, @user.email = params[:user][:nick], params[:user][:email]
    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "You are now a registered user! Welcome!"
      redirect_to @user
    else
      flash.now[:warning] = "There was an issue with the registration form."
      render :action => 'new'
    end
  end
  
  def edit
    return unless (setup && @user.editable_by?(@viewer))      
  end
  
  def update
    return unless (setup && @user.editable_by?(@viewer))
    if @user.update_attributes(params[:user])
      flash[:notice] = "You have successfully edited #{@user.display_name}."
      redirect_to @user
    else
      flash.now[:warning] = "There was an issue with the update form."
      render :action => 'edit'
    end
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
    flash[:notice] = "You are now logged out. See you soon!"
    redirect_to user_url(User.find(session[:user_id]))
    session[:user_id] = nil
    reset_session
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
