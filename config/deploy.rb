set :application, "colinsite"
set :repository,  "g5:/Users/caleon/repos/colinsite.git"
set :domain, "webserver"

set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
ssh_options[:paranoid] = false
set :user, "sshuser" # FIXME
set :runner, "mongrel"
set :user_sudo, false

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :scm, :git
set :deploy_via, :remote_cache

role :app, "your app-server here" # set these to "domain" instead, i.e.
# role :app, domain
role :web, "your web-server here"
role :db,  "your db-server here", :primary => true

# moves over config files after deploying the code
task :update_config, :roles => [ :app ] do
  run "cp -Rf #{shared_path}/config/* #{release_path}/config/"
end
after "deploy:update_code", :update_config
