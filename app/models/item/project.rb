class Project < Item
  set_table_name 'projects'
  
  alias :portfolio :list
  alias :portfolio= :list=
  
end
