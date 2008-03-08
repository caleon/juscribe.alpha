class Countdown < List
  set_itemizables :items, :order => 'position DESC' # This is simply to override the ordering
end
