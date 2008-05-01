class MainController < ApplicationController
  def index
    redirect_to :controller => 'users', :action => 'show', :id => 'colin'
  end
  
  def contents
    
  end
  
  def help
    
  end
  
  def about
    
  end
  
  def copyright
    
  end
end
