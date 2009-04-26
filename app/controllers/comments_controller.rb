class CommentsController < ApplicationController
  use_shared_options :collection_owner => :commentable
  verify_login_on :edit, :update, :destroy
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
      format.xml { render :layout => false }
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
    if @commentable.allows_comments? && (get_viewer || @commentable.allows_anonymous_comments?)
      @comment = Comment.new
      @page_title = "New Comment on #{@commentable.display_name}"
      respond_to do |format|
        format.html { trender }
        format.js
      end
    else
      msg = "You need to be logged in to do that." # FIXME: this messaging should be refactored.
      session[:before_login] = request.url
      respond_to_without_type_registration do |format|
        format.html { flash[:warning] = msg; redirect_to login_url }
        format.js { flash.now[:warning] = msg; render :controller => 'users', :action => 'login' }
      end
    end
  end
  
  def create
    return unless get_commentable(:message => "Unable to find object to comment. Please check the address.") && authorize(@commentable)
    if @commentable.allows_comments? && (get_viewer || @commentable.allows_anonymous_comments?)
      @page_title = "New Comment on #{@commentable.display_name}"

      @comment = @commentable.comments.new(params[:comment].merge(:user => get_viewer, :ip_addr => request.remote_ip))
      is_comment_spam = !SITE[:disable_akismet] && is_spam?(:comment_content => @comment.body, :permalink => commentable_url_for(@commentable),
                                 :comment_type => 'comment', :comment_author => (get_viewer.nick rescue @comment.nick), :comment_author_email => (get_viewer.email rescue @comment.email))
      if !is_comment_spam && @comment.save
        msg = "You have commented on #{flash_name_for(@commentable)}."
        Notifier.deliver_comment_notification_to_commentable(@comment) if @commentable.user != get_viewer || @commentable.user.notify_for?(:comments)
        @comment.references.each do |com|
          Notifier.deliver_comment_notification_to_orig_comment(@comment, com) if com.notifies_commenter? && (com.user != @commentable.user) && com.user != get_viewer
        end
        respond_to do |format|
          format.html { flash[:notice] = msg; redirect_to comment_url_for(@comment) }
          format.js { flash.now[:notice] = msg }
        end
      else
        flash[:warning] = "There was an error commenting on #{flash_name_for(@commentable)}." +
                              (is_comment_spam ? " Our system thinks your comment was a spam. If you think this is a mistake, please contact the site administrator." : "")
        respond_to do |format|
          format.html { redirect_to commentable_url_for(@commentable) + '#commentForm' }
          format.js { render :action => 'create_error' }
        end
      end
    else
      msg = "You need to be logged in to do that." # FIXME: this messaging should be refactored.
      session[:before_login] = request.url
      respond_to_without_type_registration do |format|
        format.html { flash[:warning] = msg; redirect_to login_url }
        format.js { flash.now[:warning] = msg; render :controller => 'users', :action => 'login' }
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
      msg = "You have successfully updated #{flash_name_for(@comment)}."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to comment_url_for(@comment) }
        format.js { flash.now[:notice] = msg }
      end
    else
      flash.now[:warning] = "There was an error updating your #{flash_name_for(@comment)}."
      respond_to do |format|
        format.html { trender :edit }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def destroy
    return unless setup(:permission) && authorize(@comment, :editable => true)
    @comment.nullify!(get_viewer)
    msg = "You have deleted a comment on #{flash_name_for(@commentable)}."
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
