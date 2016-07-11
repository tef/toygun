module Toygun
  def self.keychain
    keys = JSON.parse(::Config.keychain)
    @keys ||= keys.inject({}) do |h, (k,v)| h.merge({k.to_i => v}) end
  end
end
