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
    setup
    @widgets = @user.widgets # TODO: including :widgetable not allowed. write sql.
    @skin = @user.skin
    @layout = @user.layout
    respond_to do |format|
      format.html
    end
  end
  
  def new
    
  end
  
  def create
    
  end
  
  def edit
    setup
  end
  
  def update
    setup
  end
  
  def change_password
    setup
  end
  
  def destroy
    setup
  end
  
  def login
    
  end
  
  def logout
    setup
  end
  
  def mine
    
  end
  
  def friends
    setup
    @friends = @user.friends(:include => :primary_picture)
  end
  
  def befriend
    setup
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
    setup
  end
  
  def mailbox
    setup
  end
  
  def message
    setup
  end
  
  def about
    setup
  end
  
  private
  def setup(includes=nil, opts={})
    display_error(opts) unless (params[:id] && @user = User.find_by_nick(params[:id]))
  end
end
