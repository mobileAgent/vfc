# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_vfc_session',
  :secret      => 'd57bc2058fe69a2a3527f34b109728bf1493d42b0c6547cecfba042cade8d3cef4bf96989169250c9657ea9f3d5ec788393f9ade37a68716175d10993ab7b5d5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
