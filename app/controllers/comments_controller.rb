class CommentsController < ApplicationController
  use_shared_options :collection_owner => :commentable
  verify_login_on :new, :create, :edit, :update, :destroy
  authorize_on :index, :show, :new, :create, :edit, :update, :destroy
  
  include Akismet
  
  def index
    return unless get_commentable(:message => "Unable to find the object specified. Please check the address.") && authorize(@commentable)
    find_opts = get_find_opts(:order => 'id DESC')
    @comments = @commentable.comments.find(:all, find_opts)
    @page_title = "Comments on #{@commentable.display_name}"
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def show
    return unless setup
    @page_title = @comment.display_name
    respond_to do |format|
      format.html { trender }
      format.js
      format.xml
    end
  end
  
  def new
    return unless get_commentable(:message => "Unable to find object to comment. Please check the address.") && authorize(@commentable)
    @comment = Comment.new
    @page_title = "New Comment on #{@commentable.display_name}"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def create
    return unless get_commentable(:message => "Unable to find object to comment. Please check the address.") && authorize(@commentable)
    @page_title = "New Comment on #{@commentable.display_name}"

    @comment = @commentable.comments.new(params[:comment].merge(:user => get_viewer))
    is_comment_spam = is_spam?(:comment_content => @comment.body, :permalink => commentable_url_for(@commentable),
                               :comment_type => 'comment', :comment_author => get_viewer.nick, :comment_author_email => get_viewer.email)
    if !is_comment_spam && @comment.save
      msg = "You have commented on #{@commentable.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to comment_url_for(@comment) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error commenting on #{@commentable.display_name}." +
                            (is_comment_spam ? " Our system thinks your comment was a spam. If you think this is a mistake, please contact the site administrator." : "")
      respond_to do |format|
        format.html { trender :new }
        format.js { render :action => 'create_error' }
      end
    end
  end
  
  def edit
    return unless setup && authorize(@comment, :editable => true)
    @page_title = "#{@comment.display_name} - Edit"
    respond_to do |format|
      format.html { trender }
      format.js
    end
  end
  
  def update
    return unless setup && authorize(@comment, :editable => true)
    @page_title = "#{@comment.display_name} - Edit"
    if @comment.update_attributes(params[:comment])
      msg = "You have successfully updated #{@comment.display_name}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to comment_url_for(@comment) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your #{@comment.display_name}."
      respond_to do |format|
        format.html { trender :edit }
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
    unless request.path.match(/\/([-_a-zA-Z0-9]+)\/([^\/]+)\/comments/)
      display_error(:message => "Unable to process the request. Please check the address.")
      return false
    end
    begin
      klass_name = $1.size == 1 ? {'u' => 'users', 'g' => 'groups'}[$1] : $1
      klass, id = klass_name.singularize.classify.constantize, $2
      @commentable = klass.primary_find(id, :include => :permission)
    rescue
      klass, id = Article, nil
      @commentable = Article.primary_find(params, :for_association => true, :include => :permission)
    end
    raise ActiveRecord::RecordNotFound if @commentable.nil?
    @commentable
  rescue ActiveRecord::RecordNotFound
    display_error(:message => opts[:message] || "That #{klass.to_s.humanize} could not be found. Please check the address.")
  end
end
