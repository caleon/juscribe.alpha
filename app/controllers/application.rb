# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  layout 'standard'

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a241500281274090ecdf656d5074d028'
  
  before_filter :load_config, :get_viewer
                 
  def error
    render :template => 'shared/warning'
  end
  
  def authenticate(object)
    return true if object && @viewer && object.editable_by?(@viewer)
    respond_to do |format|
      format.html { redirect_to login_users_url and return false }
      format.js { render :controller => 'users', :action => 'login' and return false }
    end
  end

  def get_viewer
    @viewer ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def verify_logged_in
    respond_to do |format|
      format.html { redirect_to login_users_url and return false unless session[:user_id] }
      format.js { render :controller => 'users', :action => 'login' and return false unless session[:user_id] }
    end
  end
  
  #######
  private
  #######
  
  def display_error(klass_name=nil)
    klass = params[:controller].singularize.capitalize.constantize
    flash[:warning] = "That #{klass_name || klass.name.humanize} could not be found."
    respond_to do |format|
      format.html { redirect_to error_path || get_error_view(:html) }
      format.js { render :layout => false,
                         :template => error_path || get_error_view(:js) }
    end
  end
  
  def get_error_view(format)
    { :html      =>  error_url,
      :js        =>  'shared/error' }[format]
  end

  def load_config
    @config = SITE
    # TODO: set up a special table where a "recheck" value can be toggled. This
    # filter will check that value each time and if it is TRUE, it'll re-load the
    # data from the yaml file. Perhaps use a "last_checked_at" column so that
    # under normal conditions, the app will automatically recheck the yaml file
    # after a certain period of time.
  end
  
end
