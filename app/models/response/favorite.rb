class Favorite < Response
  validates_uniqueness_of :user_id, :scope => [:responsible_type, :responsible_id]
  
  class << self
    def general
      find(:all, :order => 'id DESC', :limit => 5)
    end
  end
  
  class FavoriteError < StandardError; end
end
