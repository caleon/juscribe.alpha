set :application, "juscribe.com"
set :port, 2600
# set(:mongrel_conf) { "#{current_path}/config/mongrel_cluster.yml" } # Reformatted to fix a capistrano bug

ssh_options[:paranoid] = false
set :user, "colin"
# set :runner, user # user that strts up the mongrel instances. change later.
set :use_sudo, false

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
set :scm_passphrase, "macchiato" #This is your custom users password
set :repository,  "git@github.com:caleon/juscribe.git"
set :branch, "master"
set :deploy_via, :remote_cache

role :app, application
role :web, application
role :db,  application, :primary => true

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
  
  task :stop, :roles => :app do
    # Do nothing.
  end
  
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end

# moves over config files after deploying the code
desc "Moves over config files from shared path to current release after code deploy"
task :update_config, :roles => [ :app ] do
  run "cp -Rf #{shared_path}/config/* #{release_path}/config/"
end
after "deploy:update_code", :update_config

# yes, the conditional might seem redundant, but it's here mostly for placeholding purposes
desc "If shared/uploads, shared/config/ultrasphinx doesn't exist, create directory"
task :create_directories, :roles => [ :app ] do
  run "[ ! -d #{shared_path}/uploads ] && mkdir -p #{shared_path}/uploads && mkdir -p #{shared_path}/config/ultrasphinx"
end
after "deploy:cold", :create_shared_media_directory

desc "Symlink shared/uploads into current release"
task :symlink_shared_media, :roles => [ :app ] do
  run "ln -nsf #{shared_path}/uploads #{release_path}/public/images/uploads"
end
after "deploy:update_code", :symlink_shared_media

desc "Ultrasphinx related tasks"
namespace :search do
  desc "Generate config/ultrasphinx/production.conf configuration file on production"
  task :generate_conf, :roles => :app do
    run "cd #{current_release} && RAILS_ENV=production rake ultrasphinx:configure && cp #{current_release}/config/ultrasphinx/production.conf #{shared_path}/config/ultrasphinx/"
  end
  
  desc "Index and start ultrasphinx daemon"
  task :index_and_start, :roles => :app do
    run <<-EOF
      cd #{current_release} &&
      RAILS_ENV=production rake ultrasphinx:index &&
      RAILS_ENV=production rake ultrasphinx:daemon:start &&
    EOF
  end
end

desc "Stream production log"
task :tail_log, :roles => :app do
  stream "juslog" # From alias in .profile
end
