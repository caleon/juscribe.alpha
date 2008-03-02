class Portfolio < List
  has_many :projects, :foreign_key => 'list_id', :order => 'created_at DESC'
  
end