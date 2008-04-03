class Layouting < ActiveRecord::Base
  belongs_to :layoutable, :polymorphic => true
  belongs_to :user
  
  validates_presence_of :user_id, :layoutable_type, :layoutable_id
  
  LAYOUTS = %w( msm )
  
  def choose(str)
    self.name = str
    self.save
  end
end
