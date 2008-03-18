class CommentsController < ApplicationController
  use_shared_options
  verify_login_on :new, :create, :edit, :update, :destroy
  authorize_on :index, :show, :new, :create, :edit, :update, :destroy
  
  def index
    return unless get_commentable(:message => "Unable to find the object specified. Please check the address.") && authorize(@commentable)
    find_opts = get_find_opts(:order => 'id DESC')
    @comment = @commentable.comments.find(:all, find_opts)
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
  end
  
  def show
    return unless setup
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
  end
  
  def new
    return unless get_commentable(:message => "Unable to find object to comment. Please check the address.") && authorize(@commentable)
    @comment = Comment.new
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def create
    return unless get_commentable(:message => "Unable to find object to comment. Please check the address.") && authorize(@commentable)
    if @comment = @commentable.comments.create(params[:comment].merge(:user => get_viewer))
      msg = "You have commented on #{@commentable.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to commentable_url_for(@commentable) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error commenting on #{@commentable.display_name}."
      respond_to do |format|
        format.html { render :action => 'show' }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup && authorize(@comment, :editable => true)
    @page_title = "#{@comment.display_name} - Edit"
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def update
    return unless setup && authorize(@comment, :editable => true)
    if @comment.update_attributes(params[:comment])
      msg = "You have successfully updated #{@comment.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to commentable_url_for(@commentable) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your #{@comment.display_name}."
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def destroy
    return unless setup(:permission) && authorize(@comment, :editable => true)
    @comment.nullify!(get_viewer)
    msg = "You have deleted a comment on #{@commentable.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to commentable_url_for(@commentable) }
      format.js { flash.now[:notice] = msg }
    end
  end
  
  private
  # Overriding default setup method in ApplicationController
  def setup(includes=nil, error_opts={})
    return unless get_commentable
    @comment = @commentable.comments.find(params[:id], :include => includes)
    authorize(@comment)
  rescue ActiveRecord::RecordNotFound
    error_opts[:message] ||= "That Comment could not be found. Please check the address."
    display_error(error_opts) # Error will only have access to @object from the setup method.
    false
  end
  
  def get_commentable(opts={})
    return false if (possible_commentable_keys = params.keys.select{|key| key.match(/_id$/)}).empty?
    commentable_id_key = %w( picture article song project item group event entry list playlist user ).map{|kls| "#{kls}_id"}.detect do |key|
      possible_commentable_keys.include?(key)
    end
    commentable_class = commentable_id_key.gsub(/_id$/, '').classify.constantize
    if commentable_class == Article
      @commentable = Article.primary_find(params, :for_association => true, :include => :permission)
    else
      @commentable = commentable_class.primary_find(params[commentable_id_key], :include => :permission)
    end
    raise ActiveRecord::RecordNotFound if @commentable.nil?
    @commentable
  rescue ActiveRecord::RecordNotFound
    display_error(:message => opts[:message] || "That #{commentable_class} could not be found.")
    false
  end
  
  def comment_url_for(comment)
    prefix = comment.commentable_type.underscore
    instance_eval %{ #{prefix}_comment_url(comment.to_polypath) }
  end
  
  def commentable_url_for(commentable)
    prefix = commentable.class.to_s.underscore
    instance_eval %{ #{prefix}_url(commentable.to_path) }
  end
end
