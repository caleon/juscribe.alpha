module ActiveRecord::Acts::Widgetable #:nodoc:
  def self.included(base)
#    base.module_eval <<-EOS
#      def self.widgetable?; false; end
#      def widgetable?; false; end
#    EOS
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
    
    # Desired Effect:
    # SELECT articles.*, count(widgets.widgetable_id) AS my_clips_count
    # FROM articles LEFT JOIN widgets ON widgets.widgetable_id = articles.id
    # WHERE (widgets.widgetable_type = 'Article')
    # GROUP BY widgets.widgetable_id ORDER BY my_clips_count DESC LIMIT 0, 3
    def get_popular(*args)
      opts = args.extract_options!
      limit = args.shift || opts[:limit] || 20
      # TODO: This can potentially get very large. Might need to use a separate column to store clips_count and comments_count
      find(:all, :joins => :clips, :select => "#{self.table_name}.*, count(widgets.widgetable_id) AS clips_count", :group => :widgetable_id, :order => "#{self == Article ? 'articles.comments_count DESC, ' : ''}clips_count DESC, #{self.table_name}.created_at DESC", :limit => limit, :conditions => opts[:conditions])
    end
  end

  module InstanceMethods
    # TODO: Create descriptions field in widgets table
    def clip_for(user)
      self.clips.find_by_user_id(user.id) rescue nil
    end
    
    def clip_for?(user)
      !self.clips.find_by_user_id(user.id).blank? rescue false
    end
    
    def clip!(attrs={})
      raise ArgumentError, "Hash pair for :user_id/:user must be supplied." unless attrs[:user_id] ||= (attrs[:user].id if attrs[:user])
      pos = attrs.delete(:position)
      cl = self.clips.new(attrs)
      cl.place(pos) if pos
      if cl.save
        return cl
      else
        return false
      end
    end
    
    def unclip!(attrs={})
      raise ArgumentError, "Hash pair for :user_id/:user must be supplied." unless attrs[:user_id] ||= (attrs[:user].id if attrs[:user])
      self.clips.find_by_user_id(attrs[:user_id]).destroy rescue nil
    end
    
    def widgetable?; true; end
  end
end
