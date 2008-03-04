module PluginPackage
  def self.included(base)
    ['acts_as_accessible', 'acts_as_responsible', 'acts_as_taggable',  'acts_as_widgetable'].each do |plugin|
      base.send(plugin)
    end
    base.send(:include, Layoutable)
  end
end