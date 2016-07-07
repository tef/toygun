require 'hiredis'
require 'redis'

REDIS = Redis.new(url: Config.redis_url)
