set :application, "juscribe.com"
set :port, 2600
set(:mongrel_conf) { "#{current_path}/config/mongrel_cluster.yml" } # Reformatted to fix a capistrano bug

ssh_options[:paranoid] = false
set :user, "colin"
set :runner, user # user that strts up the mongrel instances. change later.
set :user_sudo, false

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/home/colin/public_html/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
default_run_options[:pty] = true
set :scm, :git
set :scm_username, 'caleon'
set :scm_passphrase, "redalert" #This is your custom users password
set :repository,  "git@github.com:caleon/juscribe.git"
set :branch, "origin/master"
set :deploy_via, :remote_cache

role :app, application
role :web, application
role :db,  application, :primary => true

# moves over config files after deploying the code
task :update_config, :roles => [ :app ] do
  run "cp -Rf #{shared_path}/config/* #{release_path}/config/"
end
after "deploy:update_code", :update_config

task :symlink_shared_media, :roles => [ :app ] do
  run "ln -s #{shared_path}/uploads #{release_path}/public/images/uploads"
end
after "deploy:update_code", :symlink_shared_media
