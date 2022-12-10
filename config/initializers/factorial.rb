# frozen_string_literal: true

#
# $Id$
#
class Integer
  def factorial
    (1..self).reduce(:*) || 1
  end
end
