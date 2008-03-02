class Playlist < List
  has_many :songs, :foreign_key => 'list_id'

end