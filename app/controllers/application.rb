class ApplicationController < ActionController::Base
  
  ######################################################################
  ##                                                                  ##
  ##    A P P L I C A T I O N    S E T U P                            ##
  ##                                                                  ##
  ######################################################################
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a241500281274090ecdf656d5074d028'
  filter_parameter_logging :password, :password_confirmation
  exempt_from_layout('js.erb') # Do we really want this?
  class_inheritable_reader :shared_setup_options
  before_filter :load_config, :get_viewer, :verify_logged_in
  helper :all  
  layout 'standard'
  
  def load_config
    # TODO: set up a special table where a "recheck" value can be toggled. This
    # filter will check that value each time and if it is TRUE, it'll re-load the
    # data from the yaml file. Perhaps use a "last_checked_at" column so that
    # under normal conditions, the app will automatically recheck the yaml file
    # after a certain period of time.
    @config = SITE
  end
  private :load_config
  
  
  ######################################################################
  ##                                                                  ##
  ##    C O M M O N    A C T I O N S                                  ##
  ##                                                                  ##
  ######################################################################
  
  def index
    limit, page = 20, params[:page].to_i + 1
    offset = params[:page].to_i * limit
    @objects = shared_setup_options[:model_class].find(:all, :limit => limit, :offset => offset, :order => 'id DESC')
    set_model_instance(@objects)
    respond_to do |format|
      format.html
      format.xml
    end
  end
  
  def show(*args, &block)
    yield :before if block_given?
    options = args.extract_options!
    includes = options[:include]
    error_opts = options[:error_opts]
    yield :before_setup if block_given?
    return unless setup(includes, error_opts)
    yield :after_setup if block_given?
    yield :before_response if block_given?
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
    yield :after_response if block_given?
  end
  
  def new
    @page_title = "Create #{shared_setup_options[:instance_name]}"
    @object = shared_setup_options[:model_class].new
    set_model_instance(@object)
  end
  
  def create(*args, &block)
    yield :before if block_given?
    options = args.extract_options!
    without_association = options[:without_association]
    yield :before_instantiate if block_given?
    @object = @klass.new(params[shared_setup_options[:instance_sym]].merge(without_association ? {} : {:user => @viewer}))
    set_model_instance(@object)
    yield :after_instantiate if block_given?
    yield :before_save if block_given?
    if @object.save
      yield :after_save if block_given?
      msg = "You have successfully created your #{shared_setup_options[:instance_name]}."
      yield :before_response if block_given?
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @object }
        format.js { flash.now[:notice] = msg }
      end
      yield :after_response if block_given?
    else
      yield :after_not_save if block_given?
      flash.now[:warning] = "There was an error creating your #{shared_setup_options[:instance_name]}."
      yield :before_error_response if block_given?
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js { render :action => 'create_error' }
      end
      yield :after_error_response if block_given?
    end
  end
  
  def edit
    return unless setup(:permission)
    @page_title = "#{@object.display_name} - Edit"
  end
  
  def update(*args, &block)
    yield :before if block_given?
    yield :before_setup if block_given?
    return unless setup
    yield :after_setup if block_given?
    if @object.update_attributes(params[shared_setup_options[:instance_sym]])
      yield :after_save if block_given?
      msg = "You have successfully updated #{@object.display_name}."
      yield :before_response if block_given?
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to @object }
        format.js { flash.now[:notice] = msg }
      end
      yield :after_response if block_given?
    else
      flash.now[:warning] = "There was an error updating your #{shared_setup_options[:instance_name]}."
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
  
  def clip
    return unless setup
    @object.clip!(:user => @viewer)
    msg = "You have clipped #{@object.display_name}."
    respond_to do |format|
      format.html { flash[:notice] = msg; redirect_to @object }
      format.js { flash.now[:notice] = msg; render :action => 'shared/clip' }
    end
  rescue
    flash.now[:warning] = msg
    respond_to do |format|
      format.html { render :action => 'show' }
      format.js { render :action => 'shared/clip_error' }
    end
  end
  
  
  ######################################################################
  ##                                                                  ##
  ##    A C T I O N    S E T U P                                      ##
  ##                                                                  ##
  ######################################################################
  
  private
  def get_viewer
    @viewer ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def setup(includes=nil, opts={})
    self.class.set_model_variables unless klass = shared_setup_options[:model_class]
    instance_var = shared_setup_options[:instance_var]
    custom_finder = self.class.read_inheritable_attribute(:custom_finder)
    custom_finder = shared_setup_options[:custom_finder]
    
    if params[:id] && @object = klass.send(custom_finder, params[:id], {:include => includes})
      set_model_instance(@object)
      true && authorize(@object)
    else
      opts[:message] ||= "That #{klass} entry could not be found. Please check the address."    # FIXME: setting this interferes with error view processing
      display_error(opts) # Error will only have access to @object from the setup method.
      false
    end
  end
  
  def self.set_model_variables(*args)
    opts = args.extract_options!
    if args.first.is_a?(Class)
      klass_sym = args.shift
      klass = klass_sym.to_s.classify.constantize
    else
      klass = opts[:model_class] || controller_name.classify.constantize
    end
    instance_sym = klass.class_name.underscore
    instance_name = instance_sym.to_s.gsub('_', ' ')
    instance_var = "@#{instance_sym}"
    plural_sym = :"#{instance_sym.to_s.pluralize}"
    write_inheritable_attribute(:shared_setup_options, {
            :model_class      =>  klass,
            :instance_sym     =>  instance_sym,
            :instance_name    =>  instance_name,
            :instance_var     =>  instance_var,
            :plural_sym       =>  plural_sym,
            :custom_finder    =>  :find
    }.merge(opts))
  end
  
  def set_model_instance(object)
    instance_eval %{ #{object.is_a?(Array) ? shared_setup_options[:plural_sym] : shared_setup_options[:instance_var]} = object }
  end
    
  def self.verify_login_on(*args)
    write_inheritable_array :verify_login_list, args
  end
  verify_login_on :new, :create, :edit, :update, :destroy # DEFAULTS

  # verify_logged_in is called from before_filter
  def verify_logged_in
    return true unless (self.class.read_inheritable_attribute(:verify_login_list) || []).include?(action_name.intern)
    return true if get_viewer
    msg = "You need to be logged in to do that."
    respond_to_without_type_registration do |format|
      format.html { flash[:warning] = msg; redirect_to login_url and return false }
      format.js { flash.now[:warning] = msg; render :controller => 'users', :action => 'login' and return false }
      # Could just make both formats flash and render login...
    end
  end

  def self.authorize_on(*args)
    write_inheritable_array :authorize_list, args
  end
  authorize_on :edit, :update, :destroy # DEFAULTS
  
  # authorize(@object) is called within setup.
  def authorize(object)
    return true unless (self.class.read_inheritable_attribute(:authorize_list) || []).include?(action_name.intern)
    unless object && @viewer && object.editable_by?(@viewer)
      msg = "You are not authorized for that action."
      respond_to_without_type_registration do |format|
        format.html { flash[:warning] = msg; redirect_to @viewer || login_url }
        format.js { flash.now[:warning] = msg; render :action => 'shared/unauthorized' }
      end
      return false
    end
    true
  end
  
  
  ######################################################################
  ##                                                                  ##
  ##    P I C T U R E    H A N D L I N G                              ##
  ##                                                                  ##
  ######################################################################
  
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
      redirect_to error_pathing || error_url
    else
      flash.now[:warning] = msg
      render error_pathing || { :template => 'shared/error' }
    end
  end
end
