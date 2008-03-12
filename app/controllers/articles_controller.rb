class ArticlesController < ApplicationController
  use_shared_options :custom_finder => :find_by_path
  
  verify_login_on :new, :create, :edit, :update, :publish, :unpublish
  
  def index
    unless @user = User.primary_find(params[:nick])
      display_error(:message => 'That user could not be found.')
      return
    end
    find_opts = get_find_opts(:order => 'id DESC')
    @articles = @user.articles.find(:all, find_opts)
  end
  
  def list(*articles)
    
  end
  
  def show
    super(:include => [ :user, :comments ])
  end
  
  def new
    if !(@user = User.primary_find(params[:nick]))
      display_error(:message => "That User could not be found. Please check your address.")
      return
    elsif @user != get_viewer
      redirect_to new_article_url(get_viewer)
    end
    @article = Article.new
  end
  
  def create
    @article = get_viewer.articles.new(params[:article])
    if @article.save
      create_uploaded_picture_for(@article) if picture_uploaded?
      msg = "You have successfully created your article."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @article.hash_for_path }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error creating your article."
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js { render :action => 'created_error' }
      end
    end
  end
  
  private
  def setup(includes=nil, error_opts={})
    @user = User.primary_find(params[:nick]) if params[:nick]
    if only_permalink_provided? && (arts = Article.find_all_by_permalink(params[:permalink], :include => includes)).size > 0
      if arts.size == 1
        redirect_to arts.first.hash_for_path, :status => 303 and return false
      else
        flash.now[:warning] = "Multiple articles were found with that address."
        list(*arts)
        render :action => 'list' and return false
      end
    elsif only_permalink_and_nick_provided? && (arts = Article.find_all_by_permalink_and_nick(params[:permalink], params[:nick], :include => includes)).size > 0
      redirect_to arts.first.hash_for_path, :status => 303 and return false
    elsif params_valid? && @article = Article.primary_find(valid_params, :include => includes)
      if params[:month] !~ /\d\d/ || params[:day] !~ /\d\d/
        redirect_to @article.hash_for_path, :status => 301 and return false
      else
        true && authorize(@article)
      end
    else
      error_opts[:message] ||= "That article could not be found. Please check the address."
      display_error(error_opts) and return false
    end
  end
  
  def params_valid?
    params[:year] && params[:month] && params[:day] && params[:permalink] && params[:nick]
  end
  
  def valid_params
    { :year => params[:year], :month => params[:month], :day => params[:day], :permalink => params[:permalink], :nick => params[:nick] }
  end
  
  def only_permalink_and_nick_provided?
    params[:permalink] && params[:nick] && !(params[:year] && params[:month] && params[:day])
  end
  
  def only_permalink_provided?
    params[:permalink] && !(params[:year] && params[:month] && params[:day] && params[:nick])
  end
  
end
