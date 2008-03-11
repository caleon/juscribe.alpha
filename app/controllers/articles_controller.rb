class ArticlesController < ApplicationController
  set_model_variables :custom_finder => :find_by_path
  
  verify_login_on :new, :create, :edit, :update, :publish, :unpublish
  
  def index
    find_opts = get_find_opts(:order => 'id DESC')
    @user = User.primary_find(params[:user_id])
    @objects = @user.articles.find(:all, find_opts)
  end
  
  def show
    super(:include => [ :user, :comments ])
  end
  
  def view
    return unless setup(:include => [ :user, :comments ])
    render :action => 'show'
  end
  
  private
  def setup(includes=nil, error_opts={})
    if @object = Article.primary_find(params[:path], :include => includes)
      # TODO: Set permanently moved response status code.
      set_model_instance(@object)
      true && authorize(@object)
    else
      error_opts[:message] ||= "That article could not be found. Please check the address."
      display_error(error_opts)
      false
    end
  end
end
