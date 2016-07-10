module Toygun
  class Clock
    def start
      q = RedisQueue.new(redis: REDIS, queue: "resources")

      ds = Resource.active
      while true
        if q.size < 10  && ds.count > 0
          ds.select_map(:uuid).map do |uuid|
            q.push({:class => "Resource", :primary_key => uuid, :method => "tick"})
          end
        end
      sleep 1
      end
    end
  end
end
