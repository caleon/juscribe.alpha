class Tagging < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
  
  # We don't mind multiple taggings of same tag. They can then be used as threshold parameter.
  # validates_uniqueness_of :tag_id, :scope => [:taggable_type, :taggable_id]
  
  def self.tagged_class(taggable)
    ActiveRecord::Base.send(:class_name_of_active_record_descendant, taggable.class).to_s
  end
  
  def self.find_taggable(tagged_class, tagged_id)
    tagged_class.constantize.find(tagged_id)
  end
  
  def path_name_prefix
    [ self.taggable.path_name_prefix, 'tag' ].join('_')
  end
  
  def to_path(for_associated=false)
    { :"#{for_associated ? 'tag_id' : 'id'}" => self.tag.to_param }.merge(self.taggable.nil? ? {} : self.taggable.to_path(true))
  end
end
