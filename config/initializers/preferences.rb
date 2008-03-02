APP =
YAML.load_file("#{RAILS_ROOT}/config/preferences/app.yml").merge({
          :name           =>    'colin',
          :mailer_from    =>    'colin <autoNotify@venturous.net>'})
DB =
YAML.load_file("#{RAILS_ROOT}/config/preferences/db.yml")[RAILS_ENV]

SITE =
YAML.load_file("#{RAILS_ROOT}/config/preferences/site.yml")

RESPONSE_PREFS =
YAML.load_file("#{RAILS_ROOT}/config/preferences/responses.yml")