class BlogsController < ApplicationController
  use_shared_options
  verify_login_on :new, :create, :edit, :update, :destroy
  authorize_on :show, :new, :create, :edit, :update, :destroy
  
  def index
    return unless get_bloggable
    find_opts = get_find_opts
    @blogs = @bloggable.blogs.find(:all, find_opts.merge(:include => :primary_article))
    @layoutable = @bloggable
    @page_title = "Blogs by #{@bloggable.display_name}"
    respond_to do |format|
      format.html { render :template => Blog.find(:first).layout_file(:index) if @bloggable.layout }
      format.js
      format.xml
    end
  end
  
  def show
    return unless setup([:permission, :primary_article])
    find_opts = get_find_opts
    @articles = @blog.articles.find(:all, find_opts)
    @page_title = @blog.display_name
    @layoutable = @blog
    respond_to do |format|
      format.html { render :template => @blog.layout_file(:show) if @blog.layout }
      format.js
      format.xml
    end
  end
  
  def new
    return unless get_bloggable && authorize(@bloggable, :editable => true)
    @blog = @bloggable.blogs.new
    @page_title = "New Blog"
    @layoutable = @blog
    respond_to do |format|
      format.html { render :template => @blog.layout_file(:new) if @blog.layout }
      format.js
    end
  end
  
  def create
    return unless get_bloggable && authorize(@bloggable, :editable => true)
    @blog = @bloggable.blogs.new(params[:blog].merge(:user => get_viewer))
    @page_title = "New Blog"
    @layoutable = @blog
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
        format.html do
          if @blog.layout
            render :template => @blog.layout_file(:new)
          else
            render :action => 'new'
          end
        end
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup(:permission) && authorize(@blog, :editable => true)
    @page_title = "#{@blog.display_name} - Edit"
    @layoutable = @blog
    respond_to do |format|
      format.html {  render :template => @blog.layout_file(:edit) if @blog.layout }
      format.js
    end
  end
  
  def update
    return unless setup(:permission) && authorize(@blog, :editable => true)
    @page_title = "#{@blog.display_name} - Edit"
    @layoutable = @blog
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
        format.html do
          if @blog.layout
            render :template => @blog.layout_file(:edit)
          else
            render :action => 'edit'
          end
        end
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
  
  def blog_url_for(blog, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{blog.path_name_prefix}_url(blog.to_path) }
  end
  
  def bloggable_url_for(bloggable, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{bloggable.path_name_prefix}_url(bloggable.to_path) }
  end
end
