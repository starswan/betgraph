# frozen_string_literal: true

#
# $Id$
#
require "ezcrypto"

class MasterCryptoProvider
  CONFIG = YAML.load_file(Rails.root.join("config/crypto.yml"))[Rails.env].symbolize_keys

  class << self
    delegate :encrypt, to: :key

    delegate :decrypt, to: :key

    def key
      EzCrypto::Key.with_password CONFIG[:master_key], CONFIG[:salt]
    end
  end
end
