source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0', '>= 6.0.4.1'
# Use mysql2 as the database for Active Record
gem 'mysql2'
# Use Puma as the app server
gem 'authlogic'
gem 'puma'
gem 'rswag'
gem 'scrypt'

gem 'encryptor', '3.0.0', require: false
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
gem 'redis-rails'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'cancancan'
gem 'rack-cors'
gem 'rack-timeout'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'bcrypt'
gem 'figaro'
gem 'jwt'

gem 'will_paginate'

gem 'sidekiq'

gem 'amoeba'
gem 'carrierwave'
gem 'carrierwave-base64'
gem 'method_source'
gem 'rmagick'

gem 'faraday_middleware-aws-sigv4'

gem 'elasticsearch-model', '>= 6', '< 7'
gem 'elasticsearch-rails', '>= 6', '< 7'

gem 'active_model_serializers'
gem 'dotenv-rails'
gem 'exception_notification'
gem 'rails3-generators'
gem 'range_operators'
gem 'ruby_parser'
gem 'stringex'
gem 'truncate_html'
gem 'unf'
# Profiler to optimize stuff
# source & tutorial: http://railscasts.com/episodes/368-miniprofiler
gem 'activerecord'
gem 'activerecord6-redshift-adapter'
gem 'aws-sdk'
gem 'json'
gem 'ovirt-engine-sdk'
gem 'rack-mini-profiler'
# Validate email - can be used for ActiveRecord email validation
gem 'valid_email'
# Format/parse phone
gem 'phone'
gem 'wkhtmltoimage-binary'
# Shortern URL
# gem "bitly"
gem 'pg'
gem 'tinyurl_shortener'
# Cache collection partial
# gem "multi_fetch_fragments"
# Helper gem to access cache with multiple keys
gem 'bulk_cache_fetcher'
# Use dalli (memcached) for development
# to keep it consistent with production.
# However, we don't bother to use Amazon's elasticache
# and opt in to use the local memcached instead.
# Hence, we need this gem to be installed separately
# from dalli-elasticache
gem 'dalli'
# To store data in Thread (multi-thread safe)
gem 'request_store_rails'
# Concurrent support
gem 'concurrent-ruby'
gem 'rack-attack'
gem 'net-sftp'

gem 'date_validator'
gem 'whenever'
gem 'fog'
gem 'sanitize'
gem 'nokogiri'
gem 'libxml-ruby'
gem 'maxminddb'
gem 'pdfkit'
gem 'god'
gem 'addressable'
gem 'email_verifier'
gem 'multi_json'
gem 'sidekiq-cron'
# Compress a folder
# gem "rubyzip"
# gem 'rubyzip', '>= 1.0.0' # will load new rubyzip version
# gem 'zip-zip' # will load compatibility for old rubyzip API.

# The original useragents has file not loading error. The git is a fix to it
gem 'useragents', git: 'https://github.com/liqites/useragents-rb.git'

gem 'wepay'
# Attempt on device finger-printing
gem 'net-dns'
# For accessing rest apis
gem 'rest-client'
# Create image from html
gem 'imgkit'
# A Javascript code obfuscator for ad tag
gem 'jsobfu'
gem 'uglifier'
# Used by delayed_job to daemon its process
gem 'daemons'
# Profiler to analyze app boot time
gem 'bumbler'

# Omniauth providers for affiliate login
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'

# Facebook/Instagram Graph API
gem 'koala'

gem 'google-api-client'

gem 'activerecord-import'

# Get the latest currency rates from openexchangerates.org
gem 'money-oxr'
# Helper to convert to money
gem 'monetize'

gem 'axlsx'
gem 'double-bag-ftps'
gem 'slim-rails'
# gem 'caxlsx'
# gem 'caxlsx_rails'
# gem "pg_search"
gem 'liquid'
gem 'recaptcha'
gem 'stripe'
gem 'tappay'

gem 'radius'

group :production, :staging do
  # cache using memcached & Amazon's elasticache
  gem 'dalli-elasticache'
  gem 'sentry-rails'
  gem 'sentry-ruby'
end

group :development, :test do
  gem 'capybara'
  gem 'populator'
  gem 'pry'
  gem 'pry-remote'
  # gem "factory_girl_rails"
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'factory_bot'
  gem 'launchy'
  gem 'rspec-html-matchers'
  gem 'shoulda'
  gem 'shoulda-matchers'
  # gem "rails-dev-boost"
  gem 'htmlbeautifier'
  gem 'rb-fsevent', require: false
  gem 'rb-inotify', require: false
  gem 'rufo'
  gem 'test-unit'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-rails'
  gem 'rswag-specs'
end

group :test do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'simplecov'
end

group :development do
  gem 'listen'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'bullet'
  gem 'letter_opener'
  gem 'spring'
  gem 'spring-watcher-listen'
end
