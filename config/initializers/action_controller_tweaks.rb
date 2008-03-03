module Mime
  #EXTENSIONS = EXTENSION_LOOKUP.keys.map(&:intern)
  EXTENSIONS = [:html, :js]
end

# TODO: ARE PLUGINS LOADED FIRST OR ARE INITIALIZERS?
ActionController::Base.class_eval do
  def default_render
    render unless dont_render?
  end
  private :default_render
  
  def dont_render?
    @skip_default_render == true
  end
  private :dont_render?
  
  alias_method :orig_performed?, :performed?
  def performed?
    dont_render? ? false : orig_performed?
  end
  private :performed?
end
