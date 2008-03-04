class Picture < Item
  set_table_name 'pictures'
  belongs_to :depictable, :polymorphic => true
  acts_as_list :scope => :depictable
  
  alias :gallery :list
  alias :gallery= :list=

end
