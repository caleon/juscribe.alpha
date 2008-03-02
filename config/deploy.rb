set :application, "colinsite"
set :repository,  "/usr/local/repos/colinsite.git"
set :domain, "webserver"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
set :scm, :git
set :deploy_via, :remote_cache
ssh_options[:paranoid] = false

set :user, "mongrel"
set :runner, "mongrel"
set :user_sudo, false

role :app, "your app-server here" # set these to "domain" instead, i.e.
# role :app, domain
role :web, "your web-server here"
role :db,  "your db-server here", :primary => true

# moves over config files after deploying the code
task :update_config, :roles => [ :app ] do
  run "cp -Rf #{shared_path}/config/* #{release_path}/config/"
end
after "deploy:update_code", :update_config

namespace :deploy do
 desc "Create asset packages for production" 
 task :after_update_code, :roles => [:web] do
   run <<-EOF
     cd #{release_path} && rake RAILS_ENV=production asset:packager:build_all
   EOF
 end
end