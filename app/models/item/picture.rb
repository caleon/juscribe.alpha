class Picture < Item
  set_table_name 'pictures'

  belongs_to :depictable, :polymorphic => true
  
  alias :gallery :list
  alias :gallery= :list=

end
