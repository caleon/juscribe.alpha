class Gallery < List
  has_many :pictures, :foreign_key => 'list_id', :order => :position
  
end