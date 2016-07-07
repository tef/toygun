module Toygun
  module Locks
    def self.pg_try_advisory_xact_lock(klass, key)
      lock_a, lock_b = [Zlib.crc32("#{klass.table_name}"),Zlib.crc32("#{key}")].pack('LL').unpack('ll')
      Task.db["SELECT pg_try_advisory_xact_lock(CAST(#{lock_a} as int),CAST(#{lock_b} as int))"].get
    end
  end
end

