class Permission < ActiveRecord::Base
  belongs_to :permission_rule
  belongs_to :permissible, :polymorphic => true
  
  # The following line is commented out because I need permission model to save before
  # it can be assigned its associations.
  # validates_presence_of :permissisble_id, :permissible_type
  validates_uniqueness_of :permissible_id, :scope => :permissible_type, :allow_nil => true
  
end
