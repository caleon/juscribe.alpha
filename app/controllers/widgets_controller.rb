class WidgetsController < ApplicationController
  
  
  private
  def setup(includes=nil, opts={})
    self.class.set_model_variables unless shared_setup_options[:model_class]    
    if params[:user_id] && params[:id] && @object = Widget.find(params[:id], :conditions => ["user_id = ?", params[:user_id]], :include => includes)
      set_model_instance(@object)
      true && authorize(@object)
    else
      opts[:message] ||= "That Widget could not be found. Please check the address."    # FIXME: setting this interferes with error view processing
      display_error(opts) # Error will only have access to @object from the setup method.
      false
    end
  end
end
