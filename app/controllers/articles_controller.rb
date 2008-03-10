class ArticlesController < ApplicationController
  set_model_variables :custom_finder => :find_with_url
  
  verify_login_on :new, :create, :edit, :update, :publish, :unpublish
  
  def show
    super(:include => [ :user, :comments ])
  end
  
  private
  def setup(includes=nil, error_opts={})
    if params[:user_id] && params[:year] &&
       params[:month] && params[:date] && params[:id] &&
       (@user = User.primary_find(params[:user_id])) &&
       (@object = Article.find_with_url(@user.id, params[:year], params[:month], params[:date], params[:id], :include => includes))
      set_model_instance(@object)
      true
    else
      error_opts[:message] ||= "That article could not be found. Please check the address."
      display_error(error_opts)
      false
    end
  end
end
