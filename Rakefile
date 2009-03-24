# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

task(:grab_daily_password => :environment) do
  require 'digest/sha2'
  puts Digest::SHA256.hexdigest(Time.now.utc.beginning_of_day.to_s)[0..7]
end