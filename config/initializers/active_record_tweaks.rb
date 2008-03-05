module ActiveRecord
  class Base
    class << self
      alias_method :orig_create, :create
      def create(attributes = nil, validate=false)
        if attributes.is_a?(Array)
          attributes.collect { |attr| create(attr) }
        else
          object = new(attributes)
          validate ? object.save! : object.save
          object
        end
      end
  
      def create!(attributes=nil)
        create(attributes, true)
      end
    end

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
