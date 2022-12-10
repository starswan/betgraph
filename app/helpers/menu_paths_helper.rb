# frozen_string_literal: true

#
# $Id$
#
module MenuPathsHelper
  # def boldIfActive(menu_path)
  #   if menu_path.active
  #      '<b>' + yield + '</b>'
  #   else
  #      yield
  #   end
  # end
  def path_description(menu_path)
    menu_path.name.inspect + " " + (menu_path.division ? menu_path.division.name : "")
  end
end
