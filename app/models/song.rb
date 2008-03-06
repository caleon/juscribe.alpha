class Song < ActiveRecord::Base
  belongs_to :user
  belongs_to :playlist
  acts_as_list :scope => :playlist
  
  alias :list :playlist
  alias :list= :playlist=
  alias :name :title
  alias :name= :title=
  
end
