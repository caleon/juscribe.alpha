module ActiveRecord
  module Acts #:nodoc:
    module Layoutable #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)  
      end
      
      module ClassMethods
        def acts_as_layoutable(options={})
          write_inheritable_attribute(:acts_as_layoutable_options, {
            :layoutable_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s,
            :from => options[:from],
            :destroy => options[:destroy]
          })
          
          class_inheritable_reader :acts_as_layoutable_options
                    
          include ActiveRecord::Acts::Layoutable::InstanceMethods
          extend ActiveRecord::Acts::Layoutable::SingletonMethods
        end
      end
      
      module SingletonMethods
        
      end
      
      module InstanceMethods
        

      end
    end
  end
end
