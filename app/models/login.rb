# frozen_string_literal: true

#
# $Id$
#

class Login < ApplicationRecord
  has_secure_password

  validates :name, :username, :password, presence: true
end
