ActionController::Base.logger =
          Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}_controller.log")

ActiveRecord::Base.logger =
          Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}_database.log")
# ActiveRecord::Base.logger = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}_database.log", 'daily')

ActionMailer::Base.logger =
          Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}_mailer.log")

class Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.strftime('%D %r')} (#{$$}) #{msg}\n" 
  end
end
