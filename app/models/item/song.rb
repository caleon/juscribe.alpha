class Song < Item
  set_table_name 'songs'
  
  alias :playlist :list
  alias :playlist= :list=

  def name; self.title; end
  
end
