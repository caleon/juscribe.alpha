class Response < ActiveRecord::Base
  belongs_to :responsible, :polymorphic => true
  belongs_to :user
  
  validates_presence_of :user_id
  
  def invalidate!
    self.destroy
  end
end
