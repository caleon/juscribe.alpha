class Portfolio < List
  set_itemizables :projects, :order => 'created_at DESC'
  
end