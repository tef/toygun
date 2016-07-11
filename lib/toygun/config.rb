module Toygun
  def self.keychain
    JSON.parse(::Config.keychain)
  end
end
