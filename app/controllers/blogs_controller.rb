class BlogsController < ApplicationController
  use_shared_options :collection_owner => :bloggable
  verify_login_on :new, :create, :edit, :update, :destroy
  authorize_on :index, :show, :new, :create, :edit, :update, :destroy
  
  def index
    return unless get_bloggable && authorize(@bloggable)
    find_opts = get_find_opts
    @blogs = @bloggable.blogs.find(:all, find_opts.merge(:include => :latest_articles))
    redirect_to blog_url_for(@blogs.first) and return if @blogs.size == 1 && !@bloggable.editable_by?(get_viewer)
    @page_title = "Blogs by #{@bloggable.display_name}"
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def latest_articles
    return unless get_bloggable
    @blog = @bloggable.blogs.primary_find(params[:blog_id], :include => [:permission, :latest_articles])
    raise ActiveRecord::RecordNotFound if @blog.nil? || !authorize(@blog)
    @articles = @blog.latest_articles
    @page_title = "Latest Articles from #{@blog.display_name}"
    respond_to do |format|
      format.html
      format.rss { render :layout => false }
    end
  rescue ActiveRecord::RecordNotFound
    display_error(:message => "That Blog could not be found. Please check the address.")
  end
  
  def browse_by_month
    return unless setup
    if params[:month].blank?
      raise "NEED MONTH"
    else
      year = params[:month][0..3].to_i
      month = params[:month][4..5].to_i
      @articles = @blog.find_articles_by_month(year, month)
      respond_to do |format|
        format.html
        format.js
      end
    end
  end
  
  def show
    return unless setup([:permission, :primary_article]) && authorize(@blog)
    find_opts = get_find_opts
    @page_title = @blog.display_name
    respond_to do |format|
      format.html do
        @articles = if @blog.editable_by?(get_viewer)
          @blog.all_articles.find(:all, find_opts)
        else
          @blog.articles.find(:all, find_opts)
        end
        trender
      end
      format.js { @articles = @blog.articles.find(:all, find_opts) }
      format.rss do
        @articles = @blog.articles.find(:all, find_opts)
        render :layout => false
      end
    end
  end
  
  def new
    return unless get_bloggable && authorize(@bloggable, :editable => true)
    @blog = @bloggable.blogs.new
    @page_title = "New Blog"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def create
    return unless get_bloggable && authorize(@bloggable, :editable => true)
    @blog = @bloggable.blogs.new(:user => get_viewer)
    # Need to separate out in two lines so that user is set before going to the other
    # attribute setters.
    @blog.attributes = params[:blog]
    @page_title = "New Blog"
    if @blog.save
      @blog.tag_with(params[:tagsField]) unless params[:tagsField].blank?
      create_uploaded_picture_for(@blog, :save => true) if picture_uploaded?
      msg = "You have successfully created your blog."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to blog_url_for(@blog) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error creating your blog."
      respond_to do |format|
        format.html { trender :new }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup(:permission) && authorize(@blog, :editable => true)
    @page_title = "#{@blog.display_name} - Edit"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def update
    return unless setup(:permission) && authorize(@blog, :editable => true)
    @page_title = "#{@blog.display_name} - Edit"
    if @blog.update_attributes(params[:blog])
      create_uploaded_picture_for(@blog, :save => true) if picture_uploaded?
      msg = "You have successfully updated #{flash_name_for(@blog)}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to blog_url_for(@blog) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your #{flash_name_for(@blog)}."
      respond_to do |format|
        format.html { trender :edit }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def destroy
    return unless setup(:permission) && authorize(@blog, :editable => true)
    msg = "You have successfully deleted #{flash_name_for(@blog)}."
    @blog.nullify!(get_viewer)
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to :back }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  def setup(includes=nil, error_opts={})
    return unless get_bloggable
    @blog = @bloggable.blogs.primary_find(params[:id], :include => includes)
    raise ActiveRecord::RecordNotFound if @blog.nil?
    authorize(@blog)
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That Blog could not be found. Please check the address."
    display_error(error_opts)
    false
  end
  
  def get_bloggable(opts={})
    return false if (possible_bloggable_keys = params.keys.select{|key| key.match(/_id$/)}).empty?
    bloggable_id_key = %w( group user ).map{|kls| "#{kls}_id"}.detect do |key|
      possible_bloggable_keys.include?(key)
    end
    bloggable_class = bloggable_id_key.gsub(/_id$/, '').classify.constantize
    @bloggable = bloggable_class.primary_find(params[bloggable_id_key], :include => :permission)
    raise ActiveRecord::RecordNotFound if @bloggable.nil?
    @bloggable
  rescue ActiveRecord::RecordNotFound
    display_error(:message => opts[:message] || "That #{bloggable_class} could not be found. Please check the address.")
    false
  end

end
