# Submodels are included via the environment.rb file's config.load_paths.
class List < ActiveRecord::Base  
  acts_as_taggable
  acts_as_accessible
  acts_as_responsible
  acts_as_widgetable
  
  has_many :items, :order => :position, :foreign_key => 'list_id' do
    def reversed
      find(:all, :order => 'position DESC')
    end
  end
  
  STYLES = %w( cardinal ordinal roman numerical dashed dotted )
  
end
