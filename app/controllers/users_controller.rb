class UsersController < ApplicationController
  before_filter :verify_logged_in, :except => [ :index, :list, :show, :login ]
  #FIXME: before_filter :only => [:edit, :update, :destroy, :mine] { authenticate(@user) }
  
  verify :method => :post, :only => [ ],
         :redirect_to => { :action => :index }
  
  def index
    list
    render :action => 'list'
  end
  
  def list
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
  end
  
  def befriend
    setup
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
  
  private
  def setup(includes=nil, error_path=nil)
    params[:id] ? @user = User.find_by_nick(params[:id]) : display_error
  end
end
