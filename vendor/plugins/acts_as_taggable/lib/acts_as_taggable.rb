module ActiveRecord
  module Acts #:nodoc:
    module Taggable #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)  
      end
      
      module ClassMethods
        def acts_as_taggable(options = {})
          write_inheritable_attribute(:acts_as_taggable_options, {
            :taggable_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s,
            :from => options[:from],
            :destroy => options[:destroy]
          })
          
          class_inheritable_reader :acts_as_taggable_options

          has_many :taggings, :as => :taggable, :dependent => :destroy
          has_many :tags, :through => :taggings, :group => "tags.id",
                          :select => "tags.*, count(taggings.id) as tag_count",
                          :order => "tag_count DESC"

          include ActiveRecord::Acts::Taggable::InstanceMethods
          extend ActiveRecord::Acts::Taggable::SingletonMethods          
        end
      end
      
      module SingletonMethods
        # This returns A and B for (tag1, tag2) if A or B has either tag1 or tag2.
        def find_tagged_with(*args)
          #opts = args.extract_options!
          find_by_sql([
            "SELECT DISTINCT #{table_name}.* FROM #{table_name}, tags, taggings " +
            "WHERE #{table_name}.#{primary_key} = taggings.taggable_id " +
            "AND taggings.taggable_type = ? " +
            "AND taggings.tag_id = tags.id AND tags.name IN (?)",
            acts_as_taggable_options[:taggable_type], args
          ])
        end
        
        def restricted_find_tagged_with(*args)
          opts = args.extract_options!
          # TODO: Stubbed. Make look like #find_similar
        end
      end
      
      module InstanceMethods
        def add_tag(name, opts={})
          Tag.find_or_create_by_name(name).on(self, opts)
        end
        
        def tag_with(list, opts={})
          Tag.parse(list).each do |name|
            if acts_as_taggable_options[:from]
              send(acts_as_taggable_options[:from]).tags.find_or_create_by_name(name).on(self, opts)
            else
              self.add_tag(name, opts)
            end
          end
        end

        def tag_list
          #tags.collect { |tag| righttag.name.include?(" ") ? "'#{tag.name}'" : tag.name }.join(", ")
          self.tag_name_array.join(", ")
        end
        
        def tag_name_array
          tags.map(&:name)
        end
        
        def tag_collection
          tags.collect {|tag| tag.name }
        end
        
        def find_similar(limit=5, options={})
          raise "Unauthorized SQL injection attempt!" unless limit.is_a?(Fixnum)
          table_name = self.class.table_name
          class_name = self.class.class_name
          primary_key = self.class.primary_key
          self.class.find_by_sql(
              "SELECT #{table_name}.*, count(t2.id) AS similar_count FROM taggings t1 " +
              "INNER JOIN taggings t2 ON (t2.tag_id = t1.tag_id) " + 
              "INNER JOIN #{table_name} ON (#{table_name}.id = t2.taggable_id) " +
              "WHERE ((t1.taggable_type = '#{class_name}' AND t1.taggable_id = #{id}) AND " +
                  "(t2.taggable_type = '#{class_name}' AND t2.taggable_id != #{id})" +
                  ") " +
              "GROUP BY #{table_name}.#{primary_key} " +
              (options[:threshold] ? "HAVING similar_count > #{options[:threshold]} " : "") +
              "ORDER BY similar_count DESC LIMIT #{limit}")
        end

      end
    end
  end
end