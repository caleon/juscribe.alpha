class Gallery < List
  set_itemizables :pictures
  
  belongs_to :user
  
end