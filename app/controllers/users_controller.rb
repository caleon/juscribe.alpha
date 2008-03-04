class UsersController < ApplicationController
  #before_filter :verify_logged_in, :except => [ :index, :list, :show, :login, :friends ]
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
    
  end
  
  def logout
    setup
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
