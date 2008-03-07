module ActiveRecord
  class Base
    # The following is to allow either a model or its ID to be supplied as
    # arguments to a method.  
    def to_id; self[:id].to_i; end
  
    def internal_name(opts={})
      "#{self.to_param} (#{self.class}-#{self[:id]})"
    end
    
    def display_name(opts={})
      "#{self.to_param} (#{self.class})"
    end
  end
end


## acts_as_list fix For Widgetable
module ActiveRecord::Acts::List::InstanceMethods
  def add_to_list_bottom
    self[position_column] = bottom_position_in_list.to_i + 1 unless (self.new_record? && self.is_a?(Widget))
  end
  private :add_to_list_bottom
end
