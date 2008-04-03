module ActiveRecord
  class Base    
    def self.primary_find(*args); find(*args); end
    
    # The following is to allow either a model or its ID to be supplied as
    # arguments to a method.  
    def to_id; self[:id].to_i; end
    
    def to_s
      self.name rescue self.title
    rescue
      nil
    end
    
    def to_path(for_associated=false)
      { :"#{for_associated ? "#{self.class.to_s.underscore.singularize}_id" : 'id'}" => self.to_param }
    end
  
    def internal_name(opts={}); "#{self.to_param} (#{self.class}-#{self[:id]})"; end
    
    def display_name(opts={}); "(#{self.class}) #{self.to_param}"; end
    
    def nullify!(user=nil)
      (user && user.wheel?) ? destroy! : (self.nullify if self.editable_by?(user) rescue nil)
      # Wheel can destroy. Admins cannot.
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
    
    
    # LAYOUTABLE WORK. In model set belongs_to :blog, :inherits_layout => true   
    def layoutable; nil; end

    # FIXME: this is ugly
    def layouting
      self.layoutable ? self.layoutable.layouting : Layouting.find_by_layoutable_type_and_layoutable_id(self.class.class_name, self.id)
    end
    
    def layout_name=(str)
      if self.layouting
        self.layouting.choose(str)
      else
        self.create_layouting(:name => str, :user => self.user)
      end
    end
    
    def layout_name
      self.layouting && !self.layouting.name.blank? ? self.layouting.name : nil
    end
  
    def layout_file(*args)
      file = args.pop
      arr = if view_dir = args.shift
        [ view_dir.to_s, file.to_s ]
      else
        [ self.class.class_name.pluralize.underscore, file.to_s ]
      end
      return nil unless self.layout_name
      arr.unshift("/layouts/#{self.layout_name}")
      arr.join('/')
    end

    def skin_name
      self.layouting.skin || self.layout_name
    rescue
      nil
    end
  
    def skin_file
      "skins/" + skin_name if skin_name
    end
  end
  
  module Associations::ClassMethods
    def belongs_to_with_layout_inheritance(association_id, options = {})
      self.class_eval %{ def layoutable; #{association_id}; end } if options.delete(:inherits_layout)
      belongs_to_without_layout_inheritance(association_id, options)
    end
    alias_method_chain :belongs_to, :layout_inheritance
  end
  
  ## acts_as_list fix For Widgetable
  module Acts::Listable::InstanceMethods
    def add_to_list_bottom_with_filter
      self[position_column] = bottom_position_in_list.to_i + 1 unless self.is_a?(Widget)
    end
    alias_method_chain :add_to_list_bottom, :filter
    private :add_to_list_bottom
  end
end
