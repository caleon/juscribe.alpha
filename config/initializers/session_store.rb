# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_jusc_session',
  :secret      => '14201346f176220a6fd59e102ee27614079c0e5767d4607e692751727a9074bc0e737ac94a08c880ffbdc17ef63d3ba81a7850dc26b11de5f27331c16be9566b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
