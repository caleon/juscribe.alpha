require File.join(RAILS_ROOT,  'lib/active_record/validations/constants') unless Object.const_defined?(:REGEXP)

module ActiveRecord::Validations::RoutingHelper
  def regex_for(model, field)
    (REGEX[model][field] rescue nil) || REGEX[field]
  end
end