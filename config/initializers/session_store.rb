# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_juscribe_session',
  :secret      => 'ffb29f12ce298eaee1a1b047107a55f5b81ee3a769d8309280bf2944b21cec029c755dfbdfa811fc9395907733be0f090a54a4d032f6fff918153a936c5ec609'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
