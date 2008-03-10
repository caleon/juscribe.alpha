module ActiveRecord::Acts::Widgetable #:nodoc:
  def self.included(base)
    base.class_eval <<-EOS
      def self.widgetable?; false; end
      def widgetable?; false; end
    EOS
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_widgetable(options={})
      write_inheritable_attribute(:acts_as_widgetable_options, {
        :widgetable_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
      })
    
      class_inheritable_reader :acts_as_widgetable_options
    
      has_many :clips, :class_name => 'Widget', :as => :widgetable do
        def placed
          find(:all, :conditions => "position IS NOT NULL")
        end
        def unplaced
          find(:all, :conditions => "position IS NULL")
        end
      end

      include ActiveRecord::Acts::Widgetable::InstanceMethods
      extend ActiveRecord::Acts::Widgetable::SingletonMethods
    end
  end

  module SingletonMethods
    def widgetable?; true; end
  end

  module InstanceMethods
    def picture
      self.pictures.first
    rescue
      super rescue nil # FIXME: super goes to class? looks fishy.
    end
    
    def picture_file
      self.picture ? self.picture.file_path : "uploads/" + self.class.class_name + "/default.jpg" 
    end
    
    def clip_for(user)
      self.clips.find_by_user_id(user.id) rescue nil
    end
    
    def clip_for?(user)
      !self.clips.find_by_user_id(user.id).blank? rescue false
    end
    
    def clip!(attrs={})
      raise ArgumentError, "Hash pair for :user_id/:user must be supplied." unless attrs[:user_id] ||= (attrs[:user].id if attrs[:user].is_a?(User))
      pos = attrs.delete(:position)
      cl = self.clips.new(attrs)
      cl.place(pos) if pos
      cl.save ? cl : false
    end
    
    def unclip!(attrs={})
      raise ArgumentError, "Hash pair for :user_id/:user must be supplied." unless attrs[:user_id] ||= (attrs[:user].id if attrs[:user].is_a?(User))
      self.clips.find_by_user_id(attrs[:user_id]).destroy rescue nil
    end
    
    def widgetable?; true; end
  end
end
