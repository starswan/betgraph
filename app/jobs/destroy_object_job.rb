# frozen_string_literal: true

#
# $Id$
#
class DestroyObjectJob < ApplicationJob
  queue_priority PRIORITY_DESTROY_OBJECT

  def perform(object)
    object.really_destroy!
  end
end
