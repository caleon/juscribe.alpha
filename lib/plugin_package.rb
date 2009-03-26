module PluginPackage
  def self.included(klass)
    klass.extend(ClassMethods)
  end
  
  module ClassMethods
    def include_custom_plugins(opts={})
      ([ :acts_as_accessible, :acts_as_depictable, :acts_as_taggable, :acts_as_widgetable ] - Array(opts[:except])).each do |plug|
        self.send(plug)
       end      
    end
  end
end