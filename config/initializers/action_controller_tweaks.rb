module Mime
  EXTENSIONS = EXTENSION_LOOKUP.keys.map(&:intern)
  #EXTENSIONS = [:html, :js]
end

# This was to step around the doubleRender error, but for some reason
# now it works without using it. This also requires setting the instance
# variable @skip_default_render to true in a controller action of choosing.
#ActionController::Base.class_eval do
#  alias_method :orig_default_render, :default_render
#  def default_render
#    render unless dont_render?
#  end
#  private :default_render
#  
#  def dont_render?
#    @skip_default_render == true
#  end
#  private :dont_render?
#  
#  alias_method :orig_performed?, :performed?
#  def performed?
#    dont_render? ? orig_performed? : orig_performed?
#  end
#  private :performed?
#end
