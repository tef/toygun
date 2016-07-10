module Toygun
  class RedisQueue
    class Codec < JsonObjectCodec
      def dump_json(o)
        super(o).to_json
      end

      def parse_json(o)
        super(JSON.parse(o))
      end
    end

    def initialize(redis:, queue:)
      @redis = redis
      @queue = queue
      @codec = RedisQueue::Codec.new
    end

    attr_reader :redis, :queue

    def push(msg)
      redis.rpush queue, @codec.dump_json(msg)
    end

    def size
      redis.llen queue
    end

    def clear!
      redis.del queue
    end

    def pop
      raw_msg = redis.lpop queue
      @codec.parse_json(raw_msg)
    end
  end
end
