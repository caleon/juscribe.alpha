# Submodels are included via the environment.rb file's config.load_paths.
class List < ActiveRecord::Base  
  class << self
    # Usage: set_itemizables :songs, :order => :position
    def set_itemizables(*args)
      opts = args.extract_options!
      sym = args.shift || :items
      options = { :order => :position,
                  :foreign_key => 'list_id' }.merge(opts)
      has_many sym, options do
        def descending; find(:all, :order => 'position DESC'); end
        def ascending; find(:all, :order => 'position ASC'); end
      end
      if sym != :items # Override the methods inherited from List.
        # List#items is needed for general methods performed by Widget.
        has_many :items, options.merge(:class_name => sym.to_s.classify)
      end
    end
    private :set_itemizables
  end
  
  set_itemizables
  include PluginPackage

  belongs_to :user
  
  STYLES = %w( cardinal ordinal roman numerical dashed dotted )
  
end
