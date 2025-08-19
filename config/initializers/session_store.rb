# Be sure to restart your server when you modify this file.

DotoneApi::Application.config.session_store :redis_store,
  servers: [
    {
      url: ENV.fetch('CACHE_REDIS_URL'),
      namespace: 'session',
    },
  ],
  key: '_vibrantads.com_session',
  expire_after: 90.minutes,
  threadsafe: true
  # secure: true

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# DotoneApi::Application.config.session_store :active_record_store
