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
    
    def nullify!(user=nil)
      user.wheel? ? destroy! : (self.nullify if self.editable_by?(user) rescue nil)
    end
    def nullify # override this in individual models
      self.name += " (from #{self.inspect})"
      save unless ([:type, :depictable_type, :responsible_type, :permissible_type].select do |col|
        respond_to?(col) && self[col] = 'Deleted' + self[col]
      end +
      [:user_id].select do |col|
        respond_to?(col) && self[col] = DB[:garbage_id]
      end).empty?
    end
  end
end


## acts_as_list fix For Widgetable
module ActiveRecord::Acts::List::InstanceMethods
  def add_to_list_bottom
    self[position_column] = bottom_position_in_list.to_i + 1 unless self.is_a?(Widget)
  end
  private :add_to_list_bottom
end
