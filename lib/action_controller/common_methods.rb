module ActionController::CommonMethods
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def use_shared_options(*args)
      return if controller_name == 'application'
      opts = args.extract_options!
      if args.first.is_a?(Symbol)
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
      
      class_inheritable_reader :shared_setup_options
      before_filter :verify_logged_in
      
      include ActionController::CommonMethods::InstanceMethods
      extend ActionController::CommonMethods::SingletonMethods
    end
  end
  
  module SingletonMethods

    def verify_login_on(*args)
      write_inheritable_attribute :verify_login_list, args
    end

    def authorize_on(*args)
      write_inheritable_attribute :authorize_list, args
      # write_inheritable_array appends args into array instead of overwrite.
    end
    
  end

  module InstanceMethods
    
    def setup(includes=nil, error_opts={})
      klass = shared_setup_options[:model_class]
      instance_var = shared_setup_options[:instance_var]
      custom_finder = shared_setup_options[:custom_finder] || nil
      if instance_variable_set(instance_var, klass.send(custom_finder, params[:id], {:include => includes}) )
        true && authorize(instance_variable_get(instance_var))
      else
        error_opts[:message] ||= "That #{klass} entry could not be found. Please check the address."
        display_error(error_opts)
        false
      end
    end
    
    
    def index
      instance_variable_set("@#{shared_setup_options[:plural_sym]}", shared_setup_options[:model_class].find(:all, get_find_opts(:order => 'id DESC')) )
      respond_to do |format|
        format.html
        format.js
        format.xml
      end
    end

    def show(*args, &block)
      yield :before if block_given?
      options = args.extract_options!
      includes = options[:include]
      error_opts = options[:error_opts] || {}
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
      instance_variable_set("#{shared_setup_options[:instance_var]}", shared_setup_options[:model_class].new)
      respond_to do |format|
        format.html
        format.js
      end
    end

    def create(*args, &block)
      options = args.extract_options!
      without_association = options[:without_association]
      instance_variable_set("#{shared_setup_options[:instance_var]}",
          shared_setup_options[:model_class].new(params[shared_setup_options[:instance_sym]].merge(without_association ? {} : { :user => get_viewer }) ) )

      if instance_variable_get("#{shared_setup_options[:instance_var]}").save
        create_uploaded_picture_for(instance_variable_get("#{shared_setup_options[:instance_var]}")) if picture_uploaded?
        msg = "You have successfully created your #{shared_setup_options[:instance_name]}."
        respond_to do |format|
          format.html do
            flash[:notice] = msg
            redirect_to instance_variable_get("#{shared_setup_options[:instance_var]}")
          end
          format.js { flash.now[:notice] = msg }
        end
      else
        flash.now[:warning] = "There was an error creating your #{shared_setup_options[:instance_name]}."
        respond_to do |format|
          format.html { render :action => 'new' }
          format.js { render :action => 'create_error' }
        end
      end
    end

    def edit
      return unless setup(:permission)
      @page_title = "#{instance_variable_get("#{shared_setup_options[:instance_var]}").display_name} - Edit"
      respond_to do |format|
        format.html
        format.js
      end
    end

    def update(*args, &block)
      yield :before if block_given?
      yield :before_setup if block_given?
      return unless setup
      yield :after_setup if block_given?
      if instance_variable_get("#{shared_setup_options[:instance_var]}").update_attributes(params[shared_setup_options[:instance_sym]])
        yield :after_save if block_given?
        msg = "You have successfully updated #{instance_variable_get("#{shared_setup_options[:instance_var]}").display_name}."
        yield :before_response if block_given?
        respond_to do |format|
          format.html do
            flash[:notice] = msg
            redirect_to instance_variable_get("#{shared_setup_options[:instance_var]}")
          end
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
      msg = "You have deleted #{instance_variable_get("#{shared_setup_options[:instance_var]}").display_name}."
      instance_variable_get("#{shared_setup_options[:instance_var]}").nullify!(get_viewer)
      respond_to do |format|
        format.html { flash[:notice] = msg; redirect_to :back }
        format.js { flash.now[:notice] = msg }
      end
    end
    
    
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
    
    # authorize(@object) is called within setup.
    def authorize(object, opts={})
      return true if !opts[:manual] && !(self.class.read_inheritable_attribute(:authorize_list) || []).include?(action_name.intern)
      unless object && object.editable_by?(get_viewer)
        msg = "You are not authorized for that action."
        respond_to_without_type_registration do |format|
          format.html { flash[:warning] = msg; redirect_to get_viewer || login_url }
          format.js { flash.now[:warning] = msg; render :action => 'shared/unauthorized' }
        end
        return false
      end
      true
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
  end
end