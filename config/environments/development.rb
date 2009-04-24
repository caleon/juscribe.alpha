# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = true
# I'm turning this on because I don't want to or have the time to deal with
# reorganizing the code and make it messier.

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false
# Removed in Rails 2.1
# config.action_view.cache_template_extensions         = false

config.action_mailer.delivery_method = :test
# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

#Dependencies.log_activity = true
