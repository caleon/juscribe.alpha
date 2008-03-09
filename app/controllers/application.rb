class ApplicationController < ActionController::Base
  helper :all
  layout 'standard'
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a241500281274090ecdf656d5074d028'
  
  before_filter :load_config, :get_viewer, :run_initialize
  
### BEGIN TEMPLATE ###
  #before_filter {|controller| controller.authorize(@object) if [ :new, :create, :edit, :update, :destroy ].include?(controller.action_name.intern) }
  #before_filter :authorize
  #before_filter :verify_logged_in, :only => [ :create, :update, :destroy ]
  
  #verify :method => :get, :only => [ :index, :show, :new, :edit ]
  #verify :method => :put, :only => [ :update ]
  #verify :method => :post, :only => [ :create ]
  #verify :method => :delete, :only => [ :destroy ]
  
  def index
    limit, page = 20, params[:page].to_i + 1
    offset = params[:page].to_i * limit
    @object = @klass.find(:all, :limit => limit, :offset => offset, :order => 'id DESC')
    respond_to do |format|
      format.html
      format.xml
    end
  end
  
  def show(*args)
    yield :before
    options = args.extract_options!
    includes = options[:includes]
    error_opts = options[:error_opts]
    yield :before_setup
    return unless setup(includes, error_opts);
    yield :after_setup
    yield :before_response
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
    yield :after_response
  end
  
  def new
    @page_title = "Create #{@instance_str}"
    @object = @klass.new
  end
  
  def create(*args)
    yield :before
    options = args.extract_options!
    without_association = options[:without_association]
    yield :before_instantiate
    @object = @klass.new(params[@instance_sym].merge(without_association ? {} : {:user => @viewer}))
    yield :after_instantiate
    yield :before_save
    if @object.save
      yield :after_save
      msg = "You have successfully created your #{@instance_str}.";
      yield :before_response
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @object }
        format.js { flash.now[:notice] = msg }
      end
      yield :after_response
    else
      yield :after_not_save
      flash.now[:warning] = "There was an error creating your #{@instance_str}."
      yield :before_error_response
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js { render :action => 'create_error' }
      end
      yield :after_error_response
    end
  end
  
  def edit
    return unless setup({:permission => :permission_rule})
    @page_title = "#{@object.display_name} - Edit"
  end
  
  def update
    yield :before
    yield :before_setup
    return unless setup
    yield :after_setup
    if @object.update_attributes(params[:"#{@instance_name}"])
      yield :after_save
      msg = "You have successfully updated #{@object.display_name}."
      yield :before_response
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @object }
        format.js { flash.now[:notice] = msg }
      end
      yield :after_response
    else
      flash.now[:warning] = "There was an error updating your #{@instance_str}."
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js { render :action => 'update_error' }
      end
    end
  end
  
  def destroy
    return unless setup
    @object.nullify!(@viewer)
    msg = "You have deleted #{@object.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to :back }
      format.js { flash.now[:notice] = msg }
    end
  end
  
### END TEMPLATE ###
  
                 
  def error; render :template => 'shared/warning', :layout => false; end
  
  def authorize(object=@object)
    return true unless [ :new, :create, :edit, :update, :destroy ].include?(action_name.intern)
    object && @viewer && object.editable_by?(@viewer)
  end

  def get_viewer
    @viewer ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def verify_logged_in
    return true if session[:user_id]
    msg = "You need to be logged in to do that."
    orig_respond_to do |format|
      format.html { flash[:warning] = msg; redirect_to login_url and return false }
      format.js { flash.now[:warning] = msg; render :controller => 'users', :action => 'login' and return false }
      # Could just make both formats flash and render login...
    end
  end
  
  #######
  private
  #######
  
  def setup(includes=nil, opts={})
    @klass ||= controller_name.classify.constantize
    @instance_name ||= controller_name.singularize
    @instance_str ||= controller_name.singularize.gsub(/_/, ' ')
    @instance_var ||= "@#{controller_name.singularize}"
    @instance_sym ||= :"#{@instance_name}"
    @plural_sym ||= controller_name
    @custom_finder ||= :find
    if params[:id] && instance_variable_set(:"#{@instance_var}",
                                              @klass.send(@custom_finder, params[:id], :include => includes))
      @object = instance_variable_get(:"#{@instance_var}")
      true
    else
      display_error(opts)
      false
    end
  end
  
  def create_uploaded_picture_for(record, opts={})
    raise unless picture_uploaded? && !record.nil? && (record.respond_to?(:pictures) || record.respond_to?(:picture))
    params[:picture].merge!(:user => @viewer)
    picture = record.pictures.new(params[:picture]) rescue record.picture.new(params[:picture])
    return picture if !opts[:save]
    if opts[:respond]
      if picture.save
        msg = "Your picture has been uploaded."
        respond_to do |format|
          format.html { flash[:notice] = msg; redirect_to opts[:redirect_to] || edit_picture_url(picture) }
          format.js { flash.now[:notice] = msg }
        end # Now go to end of method to return picture back to original controller.
        # The above may not work because the respond_to is not setup like display_error with its instance_eval.
      else
        flash.now[:warning] = "Sorry, could not save the uploaded picture. Please upload another picture."
        record.errors.add(:picture, "could not be saved because " + picture.errors.full_messages.join(', '))
        return false
      end
    end
    return picture # needs to be saved elsewhere then.
  end
  
  def picture_uploaded?
    params[:picture] && !params[:picture][:uploaded_data].blank?
  end
  
  def load_config
    # TODO: set up a special table where a "recheck" value can be toggled. This
    # filter will check that value each time and if it is TRUE, it'll re-load the
    # data from the yaml file. Perhaps use a "last_checked_at" column so that
    # under normal conditions, the app will automatically recheck the yaml file
    # after a certain period of time.
    @config = SITE
  end
  
  # Example call from PermissionRulesController:
  # display_error(:class_name => 'Permission Rule', :message => 'Kaboom!',
  #               :html => {:redirect => true, :error_path => @permission_rule})
  def display_error(opts={})
    valid_mimes = Mime::EXTENSIONS & (opts.keys.blank? ? [:html, :js, :xml] : opts.keys)
    valid_mimes.each do |mime|
      instance_eval %{ @#{mime}_opts = opts.delete(:#{mime}) || {} }
    end    
    orig_respond_to do |format|
      valid_mimes.each do |mime|
          instance_eval <<-EOS
            @#{mime}_opts.merge!(opts)
            format.#{mime} { return_error_view(:#{mime}, @#{mime}_opts) }
          EOS
      end
    end
  end
  
  def return_error_view(format, opts={})
    klass = opts[:class]
    klass_name = opts[:class_name] || klass.name.humanize rescue nil
    msg = opts[:message] || "Error accessing #{klass_name || 'action'}."
    error_path = opts[:error_path]
    if opts[:redirect] ||= false
      flash[:warning] = msg
      redirect_to error_path || error_url
    else
      flash.now[:warning] = msg
      render error_path || { :template => 'shared/error' }
    end
  end
end
