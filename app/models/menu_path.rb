# frozen_string_literal: true

#
# $Id$
#
class MenuPath < ApplicationRecord
  serialize :name
  acts_as_tree foreign_key: :parent_path_id
  belongs_to :sport, inverse_of: :menu_paths
  has_many :menu_sub_paths, inverse_of: :menu_path, dependent: :destroy
  has_many :menu_sub_sub_paths, class_name: "MenuSubPath", foreign_key: :parent_path_id, inverse_of: :sub_path, dependent: :destroy
  belongs_to :division, inverse_of: :menu_paths, optional: true
  validates :name, :sport, presence: true

  scope :active, -> { where(active: true) }

  def menu_paths
    children
  end

  def parent_path
    parent
  end

  def active?
    depth > 0
  end

  def lastname
    name[-1]
  end

  # Note that this has to be quite precise otherwise it doesn't work...
  def self.findAllByName(name)
    # return find_by_name name.to_yaml
    where("name = ?", name.to_yaml)
  end

  def self.findByName(name)
    # return find_by_name name.to_yaml
    where("name = ?", name.to_yaml).first
  end

  before_create do |mp|
    if mp.parent_path
      mp.sport = mp.parent_path.sport
      mp.division = mp.parent_path.division
    end
    if mp.active && !mp.division
      calendar = mp.sport.calendars.first || mp.sport.calendars.create!(name: "Default")
      mp.division = calendar.divisions.create!(name: mp.name[-1])
    end
  end

  after_create do |mp|
    menu_path = mp.parent_path
    while menu_path
      MenuSubPath.create! menu_path: menu_path, sub_path: mp
      logger.debug "Just created sub path #{mp.name.inspect} parent path #{menu_path.name.inspect}"
      menu_path = menu_path.parent_path
    end
  end
end
