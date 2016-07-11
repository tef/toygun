module Toygun
  class Worker

    def start
      q = RedisQueue.new(redis: REDIS, queue: "resources")
      while true
        if q.size > 0
          if uuid = q.pop
            tick(Resource, uuid)
          end
        else
          sleep 1
        end
      end
    end

    def tick(klass, uuid)
      Locks.with_redis_lock(klass, uuid) do 
        r = klass[uuid]
        begin
          r.tick
        rescue => e 
          STDERR.puts "Error during processing: #{$!}"
          STDERR.puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
        end
      end
    end

  end

end
