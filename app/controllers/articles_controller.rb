class ArticlesController < ApplicationController
  use_shared_options :collection_owner => :blog
  # setup will handle authorization. as well as defaults from common_methods.rb
  verify_login_on :new, :create, :edit, :update, :destroy, :publish, :unpublish
  authorize_on :show, :import, :bulk_create, :edit, :update, :publish, :unpublish, :destroy
  
  def index
    # Articles#index is for articles on a user. Blogs#show has articles on a blog ----- NO. Routes redone
    return unless get_blog
    find_opts = get_find_opts
    if request.path.match(/\/drafts/)
      unless get_viewer && !(@articles = @blog.drafts.find(:all, :conditions => ["articles.user_id = ?", get_viewer.id])).empty?
        @articles ||= []
        return display_error(:message => "You do not have drafts for #{@blog.display_name}.")
      end
    else
      if @blog.editable_by?(get_viewer)
        @articles = @blog.all_articles.find(:all, find_opts)
      else
        @articles = @blog.articles.find(:all, find_opts)
      end      
    end
    @page_title = "Articles from #{@author.display_name}'s blog: #{@blog.display_name}"
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def latest_articles
    if params[:blog_id].blank?
      if params[:user_id]
        @author = User.primary_find(params[:user_id])
      elsif params[:group_id]
        @author = Group.primary_find(params[:group_id])
      end
      @articles = @author.latest_articles
    else
      return unless get_blog
      @articles = @blog.articles.find(:all, :order => 'id DESC', :limit => 10)
    end
    @page_title = "Latest articles by #{@author.display_name}"
    respond_to do |format|
      format.rss { render :layout => false }
    end
  rescue ActiveRecord::RecordNotFound, NoMethodError
    display_error(:message => 'That author/blog could not be found. Please check the address.')
  end
  
  def show
    return unless setup(:permission)
    if @article.draft?
      return unless authorize(@article, :editable => true)
    end
    add_to_article_history(@article)
    @page_title = "#{@article.display_name}"
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def new
    return unless get_blog
    if @blog.editable_by?(get_viewer)
      @article = @blog.articles.new
      @original = Article.find(params[:re]) rescue nil
      @page_title = "New Article"
      respond_to do |format|
        format.html { trender }
        format.js
        format.xml
      end
    else
      redirect_to new_user_blog_article_url(get_viewer, @blog) and return
    end
  end
  
  def create
    return unless get_blog
    @article = @blog.articles.new(params[:article].merge(:user => get_viewer))
    @page_title = "New Article"
    if @blog.editable_by?(get_viewer) && @article.save
      create_uploaded_picture_for(@article, :save => true) if picture_uploaded?
      @article.clip!(:position => params[:widget][:position], :user => get_viewer) unless params[:widget][:position].blank?
      msg = "You have successfully created your article."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to article_url_for(@article) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error creating your article."
      respond_to do |format|
        format.html { trender :new }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def import
    return unless get_blog && authorize(@blog, :editable => true)
    @page_title = "Import blog entries"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def bulk_create
    return unless get_blog && authorize(@blog, :editable => true)
    require 'rss/2.0'
    require 'open-uri'
    @page_title = "Import blog entries"
    # Check for the latest article with a post that has special marking
    # regex check param for import_url
    limit = params[:import_limit].to_i
    # This is just for blogspot at moment
    @imported_count = 0
    open(params[:import_url]) do |http|
      response = http.read
      result = RSS::Parser.parse(response, false)
      result.items[0..limit].each do |itm|
        day, month, year = item.pubDate.match(/(\d{1,2})\s([a-zA-Z]{3})\s(\d{4})/).to_a[1..-1]
        published_at = Date.new(year.to_i, Date::ABBR_MONTHNAMES.index(month), day.to_i)
        # adjust for time zone
        imported_article = Article.new(:title => itm.title, :user => get_viewer, :content => itm.description,
                                       :published_at => published_at, :imported_at => Time.now, :blog => @blog)
        @imported_count += 1 if imported_article.save
      end
    end if limit > 0
    
    msg = "Of the posts found, #{@imported_count} were successfully imported."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to blog_url_for(@blog) }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  def edit
    return unless setup(:permission) && authorize(@article, :editable => true)
    @page_title = "#{@article.display_name} - Edit"
    @widget = @article.clip_for(get_viewer)
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def update
    return unless setup(:permission) && authorize(@article, :editable => true)
    title = params[:article].delete(:title)
    @page_title = "#{@article.display_name} - Edit"
    if @article.update_attributes(params[:article])
      create_uploaded_picture_for(@article, :save => true) if picture_uploaded?
      unless params[:widget][:position].blank?
        if clip = @article.clip_for(get_viewer)
          clip.place!(params[:widget][:position]) unless clip.position == params[:widget][:position].to_i
        else
          @article.clip!(:position => params[:widget][:position], :user => get_viewer)
        end
      end
      msg = "You have successfully updated #{@article.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to article_url_for(@article) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your article."
      respond_to do |format|
        format.html { trender :edit }
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
    return unless get_blog
    if @article = Article.primary_find(params, :include => includes)
      if @article.published? && (params[:month] !~ /\d\d/ || params[:day] !~ /\d\d/)
        redirect_to article_url_for(@article), :status => 301 and return false
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
  
  def add_to_article_history(article)
    (session[:articles_history] ||= []).delete(article.id)
    session[:articles_history].unshift(article.id)
    session[:articles_history] = session[:articles_history][0..4] if session[:articles_history].size > 5
  end
end
