module ActionController::TemplateMethods
    def self.included(base)
      base.extend(ClassMethods)
    end
  
    module ClassMethods
      def use_template(options={})
        klass = options[:model_class] || self.controller_name.classify.constantize
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
          :custom_finder    =>  :primary_find
        }.merge(options))
      
        class_inheritable_reader :shared_setup_options
        before_filter :verify_logged_in
      
        include ActionController::TemplateMethods::InstanceMethods
        extend ActionController::TemplateMethods::SingletonMethods
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
    
      def get_find_opts(hash={})
        params[:page] ||= 1
        limit, page = 20, params[:page].to_i
        offset = (page -1) * limit
        return { :limit => limit, :offset => offset }.merge(hash)
      end
    
      # authorize(@object) is called within setup.
      def authorize(object)
        return true unless (self.class.read_inheritable_attribute(:authorize_list) || []).include?(action_name.intern)
        unless object && get_viewer && object.editable_by?(get_viewer)
          msg = "You are not authorized for that action."
          respond_to_without_type_registration do |format|
            format.html { flash[:warning] = msg; redirect_to get_viewer || login_url }
            format.js { flash.now[:warning] = msg; render :action => 'shared/unauthorized' }
          end
          return false
        end
        true
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
    
    
    
      def index
        instance_eval %{
          #{shared_setup_options[:instance_var]} = #{shared_setup_options[:model_class]}.find(:all, get_find_opts(:order => 'id DESC')) }
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
         yield :before if block_given?
         options = args.extract_options!
         without_association = options[:without_association]
         yield :before_instantiate if block_given?
         instance_variable_set("#{shared_setup_options[:instance_var]}",
              shared_setup_options[:model_class].new(
                    params[shared_setup_options[:instance_sym]].merge(
                    without_association ? {} : {:user => get_viewer})) )
         yield :after_instantiate if block_given?
         if instance_variable_get("#{shared_setup_optoins[:instance_var]}").save
           yield :after_save if block_given?
           msg = "You have successfully created your #{shared_setup_options[:instance_name]}."
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
         @page_title = instance_variable_get("#{shared_setup_options[:instance_var]}").display_name + " - Edit"
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
         if instance_variable_get("#{shared_setup_options[:instance_var]}"
           ).update_attributes(params[shared_setup_options[:instance_sym]])
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
         instance_variable_get("#{shared_setup_options[:instance_var]}").nullify!(get_viewer)
         msg = "You have deleted #{instance_variable_get("#{shared_setup_options[:instance_var]}").display_name}."
         respond_to do |format|
           format.html { flash[:notice] = msg; redirect_to :back }
           format.js { flash.now[:message] = msg }
         end
       end
     
       def setup(includes=nil, error_opts={})
         klass = shared_setup_options[:model_class]
         instance_var = shared_setup_options[:instance_var]
         custom_finder = shared_setup_options[:custom_finder]
         if instance_variable_set("#{instance_var}", klass.send(custom_finder, params[:id], { :include => includes }) )
           true && authorize(instance_variable_get("#{instance_var}"))
         else
           # FIXME: setting this interferes with error view processing
           error_opts[:message] ||= "That #{klass} entry could not be found. Please check the address."
           display_error(error_opts) # Error will only have access to @object from the setup method.
           false
         end
       end

       def create_uploaded_picture_for(record, opts={})
         raise unless picture_uploaded? && !record.nil? && (record.respond_to?(:pictures) || record.respond_to?(:picture))
         params[:picture].merge!(:user => get_viewer)
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
    end

end