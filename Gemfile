source "https://rubygems.org"
ruby "2.3.1"

gem "multi_json"
gem "oj"
gem "pg"
gem "pliny", "~> 0.17"
gem "pry"
gem "puma", "~> 2.16"
gem "rack-ssl"
gem "rack-timeout", "~> 0.4"
gem "rake"
gem "rollbar", require: "rollbar/middleware/sinatra"
gem "sequel", "~> 4.34"
gem "sequel-paranoid"
gem "sequel_pg", "~> 1.6", require: "sequel"
gem "sinatra", "~> 1.4", require: "sinatra/base"
gem "sinatra-contrib", require: ["sinatra/namespace", "sinatra/reloader"]
gem "sinatra-router"
gem "sucker_punch"
gem 'hiredis', '~> 0.6.1'
gem 'redis', '~> 3.3.0', require: ['redis/connection/hiredis', 'redis']
gem 'redis-namespace'
gem 'fernet'

group :development, :test do
  gem "pry-byebug"
end

group :test do
  gem "simplecov", require: false
  gem "committee"
  gem "database_cleaner"
  gem "dotenv"
  gem "rack-test"
  gem "rspec"
  gem "rspec-its"
end
