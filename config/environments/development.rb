# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_extensions         = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

#Dependencies.log_activity = true


# The following are usually defined elsewhere but the loading/unloading of dependencies
# in Rails 2 causes various issues like the inability to find instance methods on a model
# when the collection of model objects is retrieved by @user.articles.find(...) as opposed
# to Article.find(...). This inevitably leads to defining already-defined constants APP, DB
# and SITE which is already defined in preferences.rb.
APP =
YAML.load_file("#{RAILS_ROOT}/config/preferences/app.yml")

DB =
YAML.load_file("#{RAILS_ROOT}/config/preferences/db.yml")[RAILS_ENV]

SITE =
YAML.load_file("#{RAILS_ROOT}/config/preferences/site.yml")

require "#{RAILS_ROOT}/lib/plugin_package"
require "#{RAILS_ROOT}/lib/active_record/acts/accessible"
require "#{RAILS_ROOT}/lib/active_record/acts/itemizable"
require "#{RAILS_ROOT}/lib/active_record/acts/layoutable"
require "#{RAILS_ROOT}/lib/active_record/acts/taggable"
require "#{RAILS_ROOT}/lib/active_record/acts/widgetable"
require "#{RAILS_ROOT}/lib/active_record/validations/constants"
require "#{RAILS_ROOT}/lib/active_record/validations/format_validations"
require "#{RAILS_ROOT}/lib/active_record/validations/routing_helper"

ActiveRecord::Base.send(:include, ActiveRecord::Validations::FormatValidations)
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Accessible)
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Itemizable)
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Taggable)
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Widgetable)
ActiveRecord::Base.send(:include, PluginPackage)
ActionController::Base.send(:include, ActionController::CommonMethods)

require "#{RAILS_ROOT}/app/models/article"