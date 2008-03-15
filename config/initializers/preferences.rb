APP =
YAML.load_file("#{RAILS_ROOT}/config/preferences/app.yml")

DB =
YAML.load_file("#{RAILS_ROOT}/config/preferences/db.yml")[RAILS_ENV]

SITE =
YAML.load_file("#{RAILS_ROOT}/config/preferences/site.yml")
