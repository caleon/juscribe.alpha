class Permission < ActiveRecord::Base
  belongs_to :permission_rule
  belongs_to :permissible, :polymorphic => true
  
  validates_uniqueness_of :permissible_id, :scope => :permissible_type, :allow_nil => true
  
end
