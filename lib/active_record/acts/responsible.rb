# TODO: Need to finish hooking in mailer actions
module ActiveRecord::Acts::Responsible
  def self.included(base)
    base.class_eval <<-EOS
      def self.responsible?; false; end
      def responsible?; false; end
    EOS
    base.extend(ClassMethods)  
  end

  module ClassMethods
    def acts_as_responsible(options={})
      write_inheritable_attribute(:acts_as_responsible_options, {
        :responsible_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s,
        # TODO: hook destroy callback to remove associated.
        :destroy => options[:destroy]
      })
    
      class_inheritable_reader :acts_as_responsible_options
    
      has_many :responses, :as => :responsible
      has_many :reports, :as => :responsible do
        RESPONSE_PREFS[:report].each_pair do |key, val|
          class_eval %{
            def #{key}; find(:all, :conditions => ["responses.variation = ?", #{val}]); end
          }
        end
      end
      has_many :comments, :as => :responsible, :order => 'id ASC', :dependent => :nullify
      has_many :ratings, :as => :responsible do
        def final; sum(:number) || 0; end
      end
      has_many :favorites, :as => :responsible
    
      include ActiveRecord::Acts::Responsible::InstanceMethods
      extend ActiveRecord::Acts::Responsible::SingletonMethods
    end
  end

  module SingletonMethods
    def responsible?; true; end
  end

  module InstanceMethods
    def num_reported_with(var=nil)
      self.reports.count(:all, :conditions => var ? ["variation = ?", RESPONSE_PREFS[:report][var]] : nil)
    end
  
    def reported_with?(var=:questionable)
      self.num_reported_with(var) > 0
    end
  
    def report(*args)
      attrs = args.extract_options!
      var = args.shift || :questionable
      attrs[:variation] ||= RESPONSE_PREFS[:report][var]
      self.reports.create(attrs)
    end
          
    def favorited_by?(user_id)
      user_id = user_id.id if user_id.is_a?(User)
      !self.favorites.find_by_user_id(user_id).blank?
    end
  
    def favorit(user_id)
      user_id = user_id.id if user_id.is_a?(User)
      Favorite.create(:user_id => user_id, :responsible => self)
    end
  
    # Usage: track.comment_with!(1, :secondary_id => 3, :body => "Hello")
    # Secondary_id for a comment refers to what it is replying in thread
    def comment_with(*args)
      attrs = args.extract_options!
      attrs[:responsible] = self
      Comment.create(attrs)
    end

    def rate_with(attrs={})
      attrs[:number] = APP[:rating_increment]
      attrs[:responsible] = self
      Rating.create(attrs)          
    end

    def responsible?; true; end
  end
end
