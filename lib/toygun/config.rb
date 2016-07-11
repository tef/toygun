module Toygun
  module Config

    def self.keyring
      JSON.parse(Config.keyring)
    end
  end
end
