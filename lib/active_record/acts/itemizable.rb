module ActiveRecord::Acts::Itemizable
  def self.included(base)
    base.class_eval <<-EOS
      def self.itemizable?; false; end
      def itemizable?; false; end
    EOS
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_itemizable(*args) 
      options = args.extract_options!     
      list_class_sym = args.shift || :list
      list_class = list_class_sym.to_s.classify.constantize
      list_table_name = list_class.table_name
      
      write_inheritable_attribute(:acts_as_itemizable_options, {
        :itemizable_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s,
        :list_class_name => list_class.to_s, # => "Gallery"
        :list_class => list_class, # => Gallery
        :list_class_sym => list_class.to_s.underscore.intern, # => :gallery
        :list_table_name => list_table_name, # => "lists"
        :list_class_id => list_table_name.singularize + '_id'
      })
      
      class_inheritable_reader :acts_as_itemizable_options
      
      has_one :picture, :as => :depictable
      belongs_to acts_as_itemizable_options[:list_class_sym], # => :gallery
                 :foreign_key => acts_as_itemizable_options[:list_class_id]
      if acts_as_itemizable_options[:list_class_sym] != :list
        # duplicating above association this time calling it :list.
        belongs_to :list, :class_name => acts_as_itemizable_options[:list_class_name],
                   :foreign_key => acts_as_itemizable_options[:list_class_id]
      end
      acts_as_list :scope =>
      acts_as_itemizable_options[:list_table_name].singularize.intern # => :list

      validates_uniqueness_of :id,
            :scope => :"#{acts_as_itemizable_options[:list_class_id]}" # => :list_id
      
      include ActiveRecord::Acts::Itemizable::InstanceMethods
      extend ActiveRecord::Acts::Itemizable::SingletonMethods
    end
  end

  module SingletonMethods
    def list_class # Possibly needed for custom SQL within instance methods.
      inheritable_attributes[:acts_as_itemizable_options][:list_class]
    end
          
    def list_class_sym
      inheritable_attributes[:acts_as_itemizable_options][:list_class_sym]
    end
    
    def itemizable?; true; end
  end

  module InstanceMethods
    def accessible_by?(user)
      self.list.nil? ? super : (self.list.accessible_by?(user) && super)
    end
    
    def itemizable?; true; end
  end
end