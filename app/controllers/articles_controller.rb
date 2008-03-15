class ArticlesController < ApplicationController
  use_shared_options :custom_finder => :find_by_path
  # setup will handle authorization. as well as defaults from common_methods.rb
  verify_login_on :new, :create, :edit, :update, :destroy, :publish, :unpublish
  authorize_on :edit, :update, :publish, :unpublish, :destroy
  
  def index
    # don't show drafts unless viewer == user
    unless @user = User.primary_find(params[:user_id])
      display_error(:message => 'That user could not be found.')
      return
    end
    find_opts = get_find_opts(:order => 'articles.id DESC')
    @articles = @user.articles.find(:all, find_opts)
  end
  
  def show
    return unless setup
    if @article.draft?
      return unless authorize(@article, :manual => true)
    end
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
  end
  
  def new
    if !(@user = User.primary_find(params[:user_id]))
      display_error(:message => "That User could not be found. Please check your address.")
      return
    elsif @user != get_viewer
      redirect_to new_article_url(get_viewer)
    end
    @article = Article.new
  end
  
  def create
    @article = Article.new(params[:article].merge(:user => get_viewer))
    if @article.save
      create_uploaded_picture_for(@article, :save => true) if picture_uploaded?
      msg = "You have successfully created your article."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to article_url_for(@article) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error creating your article."
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup(:permission)
    @page_title = "#{@article.display_name} - Edit"
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def update
    return unless setup
    title = params[:article].delete(:title)
    if @article.update_attributes(params[:article])
      msg = "You have successfully updated #{@article.display_name}."
      respond_to do |format|
        format.html do
          flash[:notice] = msg
          redirect_to article_url_for(@article)
        end
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your article."
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def publish
    return unless setup
    @article.publish!
    msg = "You have published #{@article.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to article_url(@article.to_path) }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  def unpublish
    return unless setup
    @article.unpublish!
    msg = "You have unpublished #{@article.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to draft_url(@article.to_path) }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  def setup(includes=nil, error_opts={})
    @user = User.primary_find(params[:user_id]) if params[:user_id]
    if only_permalink_provided? && (arts = Article.find_all_by_permalink(params[:id], :include => includes)).size == 1
      @article = arts.first
      if @article.published?
        redirect_to article_url(@article.to_path), :status => 303 and return false        
      else
        redirect_to draft_url(@article.to_path), :status => 303 and return false
      end
    elsif only_permalink_and_nick_provided? && (arts = Article.find_any_by_permalink_and_nick(params[:id], params[:user_id]))
      if @article = arts.detect {|art| art.draft? }
        true && authorize(@article)
      elsif (pub_arts = arts.select {|art| art.published? }).size == 1
        @article = pub_arts.first
        redirect_to article_url(@article.to_path), :status => 303 and return false
      else
        error_opts[:message] ||= "That article could not be found. Please check the address."
        display_error(error_opts) and return false
      end
    elsif params_valid? && @article = Article.find_by_params(valid_params, :include => includes)
      if params[:month] !~ /\d\d/ || params[:day] !~ /\d\d/
        redirect_to article_url(@article.to_path), :status => 301 and return false
      else
        true && authorize(@article)
      end
    else
      error_opts[:message] ||= "That article could not be found. Please check the address."
      display_error(error_opts) and return false
    end
  end
  
  def params_valid?
    params[:year] && params[:month] && params[:day] && params[:id] && params[:user_id]
  end
  
  def valid_params
    { :year => params[:year], :month => params[:month], :day => params[:day], :id => params[:id], :user_id => params[:user_id] }
  end
  
  def only_permalink_and_nick_provided?
    params[:id] && params[:user_id] && !(params[:year] || params[:month] || params[:day])
  end
  
  def only_permalink_provided?
    params[:id] && !(params[:year] || params[:month] || params[:day] || params[:user_id
      ])
  end
  
  def article_url_for(article)
    prefix = article.published? ? 'article' : 'draft'
    instance_eval %{ #{prefix}_url(article.to_path) }
  end
  
end
