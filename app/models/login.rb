# frozen_string_literal: true

#
# $Id$
#
require "master_crypto_provider"

class Login < ApplicationRecord
  acts_as_secure crypto_provider: MasterCryptoProvider

  validates :name, :username, :password, presence: true
end
