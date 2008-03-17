unless RAILS_ENV == 'development' # Development already has these in development.rb
APP =
YAML.load_file("#{RAILS_ROOT}/config/preferences/app.yml")

DB =
YAML.load_file("#{RAILS_ROOT}/config/preferences/db.yml")[RAILS_ENV]

SITE =
YAML.load_file("#{RAILS_ROOT}/config/preferences/site.yml")

ActionMailer::Base.smtp_settings = YAML.load(File.open("#{RAILS_ROOT}/config/mailer.yml"))
end