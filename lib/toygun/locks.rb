module Toygun
  module Locks
    def self.pg_try_advisory_xact_lock(klass, key)
      lock_a, lock_b = [Zlib.crc32("#{klass.table_name}"),Zlib.crc32("#{key}")].pack('LL').unpack('ll')
      Task.db["SELECT pg_try_advisory_xact_lock(CAST(#{lock_a} as int),CAST(#{lock_b} as int))"].get
    end

    LUA_LOCK = <<-EOS.gsub(/^\s+/, "")
      local result = redis.call('SETNX', KEYS[1], ARGV[1])
      if result == 1 then
        redis.call('EXPIRE', KEYS[1], ARGV[2])
      end
      return result
    EOS

    LUA_UNLOCK = <<-EOS.gsub(/^\s+/, "")
      if redis.call('GET', KEYS[1]) == ARGV[1] then
        return redis.call('DEL', KEYS[1])
      end
    EOS

    def self.with_redis_lock(klass, uuid, expire_secs: 60, &block)
      lock_id = SecureRandom.uuid
      key = "lock:#{klass.table_name}:#{uuid}"
      locked = false

      begin
        locked = REDIS.eval(LUA_LOCK, keys: [key], argv: [lock_id, expire_secs]) == 1
        if locked
          block.call
        end
      ensure
        if locked
          REDIS.eval(LUA_UNLOCK, keys: [key], argv: [lock_id])
        end
      end
    end
  end
end

