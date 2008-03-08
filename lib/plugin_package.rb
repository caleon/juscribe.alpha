module PluginPackage
  def self.included(klass)
    ['acts_as_accessible', 'acts_as_responsible', 'acts_as_taggable',  'acts_as_widgetable'].each do |plugin|
      klass.send(plugin)
    end
    klass.send(:include, ActiveRecord::Acts::Layoutable)
  end
end