module Itemizable
  def self.included(base)
    base.extend(ClassMethods)
    
    ActiveRecord::Base.class_eval do
      def self.itemizable?; false; end
    end
  end
  
  module ClassMethods
    cattr_accessor :list_class
    def set_list_class(arg)
      list_class = arg.constantize
    end
    
    def list_class_sym
      list_class.table_name.singularize.intern
    rescue
      set_list_class(List)
      :list
    end
    alias_method :list, list_class_sym
    alias_method :list=, :"#{list_class_sym}="
    
    def itemizable?; true; end
        
    belongs_to :user
    has_one :picture, :as => :depictable
    belongs_to list_class_sym
    acts_as_list :scope => list_class_sym
    
    validates_uniqueness_of :id, :scope => :"#{list_class_sym}_id"
    
    include ActiveRecord::Acts::Widgetable::InstanceMethods
    extend ActiveRecord::Acts::Widgetable::SingletonMethods
  end
  
  module SingletonMethods
    
  end
  
  module InstanceMethods
    def accessible_by?(user)
      self.list.nil? ? super : (self.list.accessible_by?(user) && super)
    end
  end
end