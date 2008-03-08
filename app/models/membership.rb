class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  
  validates_presence_of :user_id, :group_id
  validates_uniqueness_of :user_id, :scope => :group_id
  
  ADMIN_RANK = 8
  RANKS = { :founder          =>  10,
            :field_marshal    =>  9,
            :general          =>  8,
            :brigadier        =>  7,
            :colonel          =>  6,
            :major            =>  5,
            :captain          =>  4,
            :lieutenant       =>  3,
            :sergeant         =>  2,
            :corporal         =>  1,
            :private          =>  0 }
            
  def rank; self[:rank].to_i; end
  
end
