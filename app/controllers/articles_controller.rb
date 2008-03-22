class ArticlesController < ApplicationController
  use_shared_options :collection_layoutable => :blog
  # setup will handle authorization. as well as defaults from common_methods.rb
  verify_login_on :new, :create, :edit, :update, :destroy, :publish, :unpublish
  authorize_on :edit, :update, :publish, :unpublish, :destroy
  
  def index
    # Articles#index is for articles on a user. Blogs#show has articles on a blog ----- NO. Routes redone
    return unless get_blog
    find_opts = get_find_opts
    if @blog.editable_by?(get_viewer)
      @articles = @blog.all_articles.find(:all, find_opts)
    else
      @articles = @blog.articles.find(:all, find_opts)
    end
    @layoutable = @blog
    @page_title = "Articles from #{@bloggable.display_name}'s blog: #{@blog.display_name}"
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def show
    return unless setup(:permission)
    if @article.draft?
      return unless authorize(@article, :editable => true)
    end
    @page_title = "#{@article.display_name}"
    set_layoutable
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def new
    return unless get_blog
    if @user == get_viewer
      @article = Article.new
      @page_title = "New Article"
      @layoutable = @user
      respond_to do |format|
        format.html do
          if @article.layout
            render :template => @article.layout_file(:new)
          else
            render :action => 'show'
          end
        end
        format.js
        format.xml
      end
    else
      redirect_to new_article_url(get_viewer) and return if @user != get_viewer
    end
  end
  
  def create
    return unless get_blog
    @article = Article.new(params[:article].merge(:user => get_viewer))
    @page_title = "New Article"
    @layoutable = @article
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
        format.html do
          if @picture.layout
            render :template => @picture.layout_file(:new)
          else
            render :action => 'new'
          end
        end
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup(:permission) && authorize(@article, :editable => true)
    @page_title = "#{@article.display_name} - Edit"
    @layoutable = @article
    respond_to do |format|
      format.html do
        if @article.layout
          render :template => @article.layout_file(:edit)
        else
          render :action => 'edit'
        end
      end
      format.js
    end
  end
  
  def update
    return unless setup(:permission) && authorize(@article, :editable => true)
    title = params[:article].delete(:title)
    @page_title = "#{@article.display_name} - Edit"
    if @article.update_attributes(params[:article])
      create_uploaded_picture_for(@article, :save => true) if picture_uploaded?
      msg = "You have successfully updated #{@article.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to article_url_for(@article) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your article."
      respond_to do |format|
        format.html do
          if @article.layout
            render :template => @article.layout_file(:edit)
          else
            render :action => 'edit'
          end
        end
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def publish
    return unless setup(:permission)
    @article.publish!
    msg = "You have published #{@article.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to article_url_for(@article) }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  def unpublish
    return unless setup(:permission)
    @article.unpublish!
    msg = "You have unpublished #{@article.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to article_url_for(@article) }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  def setup(includes=nil, error_opts={})
    if @article = Article.primary_find(params, :include => includes, :viewer => get_viewer)
      if params[:month] !~ /\d\d/ || params[:day] !~ /\d\d/
        redirect_to article_url(@article.to_path), :status => 301 and return false
      else
        authorize(@article)
      end
    else
      display_error(:message => "That article could not be found. Please check the address.") and return false
    end
  end
  
  def get_blog
    @blog = if params[:user_id]
      Blog.find_by_user_and_blog(params[:user_id], params[:blog_id])
    elsif params[:group_id]
      Blog.find_by_group_and_blog(params[:group_id], params[:blog_id])
    end
    raise ActiveRecord::RecordNotFound if @blog.nil?
    @author = @blog.bloggable
    @blog
  rescue ActiveRecord::RecordNotFound
    display_error(:message => 'That blog could not be found. Please check the address.') and return false
  end
  
  def article_url_for(article)
    prefix = article.blog.bloggable_type.underscore
    prefix += article.published? ? '_article' : '_draft'
    instance_eval %{ #{prefix}_url(article.to_path) }
  end
  
end
