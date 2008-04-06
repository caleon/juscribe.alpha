class BlogsController < ApplicationController
  use_shared_options :collection_owner => :bloggable
  verify_login_on :new, :create, :edit, :update, :destroy
  authorize_on :show, :new, :create, :edit, :update, :destroy
  
  def index
    return unless get_bloggable
    find_opts = get_find_opts
    @blogs = @bloggable.blogs.find(:all, find_opts.merge(:include => :primary_article))
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
    @page_title = "Latest Articles from #{@blog.name}"
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
    return unless setup([:permission, :primary_article])
    find_opts = get_find_opts
    @articles = if @blog.editable_by?(get_viewer)
      @blog.all_articles.find(:all, find_opts)
    else
      @blog.articles.find(:all, find_opts)
    end
    @page_title = @blog.display_name
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
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
    @blog = @bloggable.blogs.new(params[:blog].merge(:user => get_viewer))
    @page_title = "New Blog"
    if @blog.save
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
      msg = "You have successfully updated #{@blog.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to blog_url_for(@blog) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your #{@blog.display_name}."
      respond_to do |format|
        format.html { trender :edit }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def destroy
    return unless setup(:permission) && authorize(@blog, :editable => true)
    msg = "You have successfully deleted #{@blog.display_name}."
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
