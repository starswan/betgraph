# frozen_string_literal: true

#
# $Id$
#
class MenuSubPath < ApplicationRecord
  belongs_to :menu_path
  belongs_to :sub_path, class_name: "MenuPath", foreign_key: :parent_path_id
end
