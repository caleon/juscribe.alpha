class ArticlesController < ApplicationController
  use_shared_options :custom_finder => :find_by_path
  
  verify_login_on :new, :create, :edit, :update, :publish, :unpublish
  
  def index
    find_opts = get_find_opts(:order => 'id DESC')
    @user = User.primary_find(params[:nick])
    @articles = @user.articles.find(:all, find_opts)
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
    if @article = Article.primary_find(params, :include => includes)
      # TODO: Set permanently moved response status code.
      true && authorize(@article)
    else
      error_opts[:message] ||= "That article could not be found. Please check the address."
      display_error(error_opts)
      false
    end
  end
end
