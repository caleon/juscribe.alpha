$:.unshift "#{File.dirname(__FILE__)}/lib"

#require "#{File.dirname(__FILE__)}/../acts_as_list/init"
#ActiveRecord::Base.class_eval { include ActiveRecord::Acts::List }
# The following is to allow new Widget clips to have a null position column value upon
# creation.

require 'acts_as_widgetable'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Widgetable)

require 'widget'

ActiveRecord::Acts::List::InstanceMethods.class_eval do
  alias_method :orig_add_to_list_bottom, :add_to_list_bottom
  def add_to_list_bottom
    self[position_column] = bottom_position_in_list.to_i + 1 unless (self.new_record? && self.is_a?(Widget))
  end
  private :add_to_list_bottom
end
