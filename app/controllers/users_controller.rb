class UsersController < ApplicationController
  before_filter :verify_logged_in, :except => [ :index, :list, :show, :login ]
  before_filter :setup, :only => [ :show, :edit, :update, :destroy, :mine ]
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
    
  end
  
  def new
    
  end
  
  def create
    
  end
  
  def edit
    
  end
  
  def update
    
  end
  
  def change_password
    
  end
  
  def destroy
    
  end
  
  def login
    
  end
  
  def logout
    
  end
  
  def mine
    
  end
  
  private
  def setup(includes=nil)
    
  end
end
