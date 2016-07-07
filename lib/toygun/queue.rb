module Toygun
  class RedisQueue
    def initialize(redis:, queue:)
      @redis = redis
      @queue = queue
    end

    attr_reader :redis, :queue

    def push(msg)
      redis.rpush queue, msg
    end

    def size
      redis.llen queue
    end

    def clear!
      redis.del queue
    end

    def pop
      msg = redis.blpop
    end
  end
  

end
