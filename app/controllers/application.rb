require 'digest/sha2'
class ApplicationController < ActionController::Base
  
  ######################################################################
  ##                                                                  ##
  ##    A P P L I C A T I O N    S E T U P                            ##
  ##                                                                  ##
  ######################################################################
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery# :secret => 'a241500281274090ecdf656d5074d028'
  filter_parameter_logging :password, :password_confirmation
  before_filter :load_config, :authenticate, :get_viewer, :clear_stale_session, :remember_daily_pw
  after_filter :set_previous_view
  layout :get_layout
  helper :all  
  
  def remember_daily_pw
    @daily_pw = Digest::SHA256.hexdigest(Time.now.utc.beginning_of_day.to_s)[0..7] if RAILS_ENV == 'development'
  end
  
  def previous_view
    #return root_url if request.env['HTTP_REFERER'].nil? || !request.env['HTTP_REFERER'].match(/http:\/\/#{request.host}/)
    session[:previous] || root_url
  end
  
  private
  def load_config
    # TODO: set up a special table where a "recheck" value can be toggled. This
    # filter will check that value each time and if it is TRUE, it'll re-load the
    # data from the yaml file. Perhaps use a "last_checked_at" column so that
    # under normal conditions, the app will automatically recheck the yaml file
    # after a certain period of time.
    @config = SITE
  end
    
  def get_viewer
    @viewer ||= (User.find(session[:id]) rescue nil) if session[:id]
  end
  
  def get_user(error_opts={})
    @user = User.primary_find(params[:user_id]) || (raise ActiveRecord::RecordNotFound)
  rescue ActiveRecord::RecordNotFound
    display_error(:message => error_opts[:message] || "That User could not be found. Please check the address.")
    return false
  end
  
  def set_previous_view
    if request.get?
      # FIXME: before_login and previous are too similar.
      session[:previous] = request.url if params[:format].blank? && !request.path.match(/^\/login/) && !request.path.match(/\.js$/)
    end
  end
  
  def clear_stale_session
    session[:before_login] = nil unless action_name == 'login' || session[:before_login].nil?
  end
  
  def get_find_opts(hash={})
    params[:page] ||= 1
    limit, page = 20, params[:page].to_i
    offset = (page -1) * limit
    return { :limit => limit, :offset => offset }.merge(hash)
  end
  
  # FIXME: Turning default skin to MSM for now.
  def get_layout
    main_object.layout_name || Layouting::DEFAULT_LAYOUT
  rescue
    Layouting::DEFAULT_LAYOUT
  end

  
  ######################################################################
  ##                                                                  ##
  ##    P I C T U R E    H A N D L I N G                              ##
  ##                                                                  ##
  ######################################################################
  
  def create_uploaded_picture_for(record, opts={})
    raise unless picture_uploaded? && !record.nil? && (record.respond_to?(:pictures) || record.respond_to?(:picture))
    params[:picture].merge!(:user => get_viewer || opts[:user])
    picture = record.pictures.new(params[:picture]) rescue record.picture.new(params[:picture])
    return picture if !opts[:save]
    if picture.save
      msg = "Your picture has been uploaded."
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to opts[:redirect_to] || picture_url_for(picture, 'edit') }
        format.js { flash.now[:notice] = msg }
      end if opts[:respond]
      # Now go to end of method to return picture back to original controller.
      # The above may not work because the respond_to is not setup like display_error with its instance_eval.
    else
      flash.now[:warning] = "Sorry, could not save the uploaded picture. Please upload another picture."
      record.errors.add(:picture, "could not be saved because " + picture.errors.full_messages.join(', '))
    end
    return picture # needs to be saved elsewhere if not opts[:save].
  end
  
  def picture_uploaded?
    params[:picture] && !params[:picture][:uploaded_data].blank?
  end
  
  ######################################################################
  ##                                                                  ##
  ##    U R L   F O Rs                                                ##
  ##                                                                  ##
  ######################################################################
  
  def picture_url_for(picture, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{picture.path_name_prefix}_url(picture.to_path) }
  end
  
  def depictable_url_for(depictable, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{depictable.path_name_prefix}_url(depictable.to_path) }
  end
  
  def article_url_for(article)
    prefix = article.blog.path_name_prefix
    prefix += article.published? ? '_article' : '_draft'
    instance_eval %{ #{prefix}_url(article.to_path) }
  end
  
  def blog_url_for(blog, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{blog.path_name_prefix}_url(blog.to_path) }
  end
  
  def bloggable_url_for(bloggable, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{bloggable.path_name_prefix}_url(bloggable.to_path) }
  end
  
  def comment_url_for(comment, acshun=nil) # FIXME: acshun probably not needed in this scenario.
#    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{comment.path_name_prefix}_url(comment.to_path) }
    commentable_url_for(comment.commentable) + "#comment-#{comment.id}"
  end
  
  def commentable_url_for(commentable, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{commentable.path_name_prefix}_url(commentable.to_path) }
  end
  
  def tagging_url_for(tagging, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{tagging.path_name_prefix}_url(tagging.to_path) }
  end
  
  def taggable_url_for(taggable, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{taggable.path_name_prefix}_url(taggable.to_path) }
  end
  
  def clip_url_for(clip, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{clip.path_name_prefix}_url(clip.to_path) }
  end
  
  def widgetable_url_for(widgetable, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{widgetable.path_name_prefix}_url(widgetable.to_path) }
  end
  
  ######################################################################
  ##                                                                  ##
  ##    E R R O R    H A N D L I N G                                  ##
  ##                                                                  ##
  ######################################################################

  def error; render :template => 'shared/warning', :layout => false; end

  # Example call from PermissionRulesController:
  # display_error(:class_name => 'Permission Rule', :message => 'Kaboom!',
  #               :html => {:redirect => true, :error_path => @permission_rule})
  def display_error(opts={})
    valid_mimes = Mime::EXTENSIONS & [:html, :js, :xml]
    valid_mimes.each do |mime|
      instance_eval %{ @#{mime}_opts = opts.delete(:#{mime}) || {} }
    end
    respond_to_without_type_registration do |format|
      valid_mimes.each do |mime|
        instance_eval %{ format.#{mime} { return_error_view(:#{mime}, @#{mime}_opts.merge!(opts)) } }
      end
    end
  end

  def return_error_view(format, opts={})
    klass = opts[:class]
    klass_name = opts[:class_name] || klass.class_name.humanize rescue nil
    msg = opts[:message] || "Error accessing #{klass_name || 'action'}."
    error_pathing = opts[:error_path]
    if opts[:redirect] ||= false
      flash[:warning] = msg
      redirect_to error_pathing || error_url, :status => 404
    else
      flash.now[:warning] = msg
      render error_pathing || { :template => 'shared/error' }
    end
  end
  
  def authenticate
    return true unless SITE[:defcon] == 0 && RAILS_ENV == 'production'
    authenticate_or_request_with_http_basic do |user_name, password| 
      user_name == 'juscriber' && password == Digest::SHA256.hexdigest(Time.now.utc.beginning_of_day.to_s)[0..7]
    end
  end
  
  def registration_closed?
    RAILS_ENV != 'test' && ((SITE[:defcon] == 0) || SITE[:disable_registration])
  end
  
end
