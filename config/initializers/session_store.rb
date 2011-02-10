# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_vtsc_session',
  :secret      => '4796e4978d82792e1ad7fbbb31af2fff94719818e6d4d693d8beff1f0472fb91768228f576bfdee9c40f0e7e0374396ac4d0dbcd0024f0d2c96e2d4710376dd7'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
