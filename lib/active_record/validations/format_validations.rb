require File.join(RAILS_ROOT,  'lib/active_record/validations/constants') unless Object.const_defined?(:REGEXP)

# An alternative way to handle this is to define a constant within each model file.
# The only issue with that is Routing won't be able to access these constants.

module ActiveRecord::Validations::FormatValidations
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def validates_with_regexp(*args)
      opts = args.extract_options!
      args.each do |field|
        validates_format_of field, { :with => field_regexp_for(field) }.merge(opts)
      end
    end
    
    def field_regexp_for(field)
      (REGEXP[self.class_name.underscore.intern][field] rescue nil) || REGEXP[field]
    end
  end
end
