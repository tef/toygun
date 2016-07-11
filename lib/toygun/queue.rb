module Toygun
  class RedisQueue
    class Codec < RecordCodec
      def dump(o)
        msg = super(o).to_json
        secret = dump_one(Secret.encrypt(msg)).to_json
      end

      def parse(o)
        secret = parse_one(JSON.parse(o))
        secret.decrypt do |msg|
          return super(JSON.parse(msg))
        end
      end
    end

    def initialize(redis:, queue:)
      @redis = redis
      @queue = queue
      @codec = RedisQueue::Codec.new
    end

    attr_reader :redis, :queue

    def push(message)
      m = @codec.dump({body: message, time: Time.now})
      redis.rpush queue, m
    end

    def size
      redis.llen queue
    end

    def clear!
      redis.del queue
    end

    def pop
      while true
        raw_msg = redis.lpop queue
        return if raw_msg == nil
        message = @codec.parse(raw_msg)
        next if message[:time] < (Time.now - 30*60) # 30 minutes
        return message[:body]
      end
    end
  end
end
