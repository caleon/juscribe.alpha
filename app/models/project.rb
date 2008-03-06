class Project < ActiveRecord::Base
  belongs_to :user
  belongs_to :portfolio
  
  alias :list :portfolio
  alias :list= :portfolio=
  
end
