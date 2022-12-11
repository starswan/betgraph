# frozen_string_literal: true

#
# $Id$
#
class MakeMenuPathsJob < BetfairJob
  # queue_priority :make_menu_paths
  queue_priority PRIORITY_MAKE_MENU_PATHS

  def perform(menu_path)
    logger.debug("MakeMenuPaths for #{menu_path.name}")

    # don't process job for Fixtures apart from this and next month
    if menu_path.name.last.starts_with? "Fixtures"
      date = Date.parse(menu_path.name.last) rescue Date.yesterday
      date = Date.new(Date.today.year, date.month, date.day)
      date = date + 1.year if date.past?
      if date - 2.months < Date.today
        just_do_it(menu_path)
      end
    else
      just_do_it(menu_path)
    end
  end

private

  def just_do_it(menu_path)
    count = MenuPath.transaction do
      make_menu_paths(menu_path)
    end
    MakeMatchesJob.perform_later(menu_path.sport) if count > 0
  end

  def make_menu_paths(menu_path)
    # logger.debug "makeMenuPaths #{menu_path.inspect}"
    pathhash = bc.getAllMarkets.collect { |market| market.menuPath }.each_with_object({}) do |menuPath, hash|
      menuPath.each_with_index do |_path, index|
        slice = index == 0 ? [] : menuPath[0..index - 1]
        (hash[slice] ||= Set.new).add menuPath[0..index]
      end
    end
    # activeSports = Sport.find_all_by_active(true)
    # activeSports.inject(0) do |total, sport|
    #   total + sport.menu_paths.inject(0) { |total, parent| total + processMenuPath(parent, pathhash) }
    # end
    process_menu_path(menu_path, pathhash)
  end

  def process_menu_path(parent, pathhash)
    count = 0
    if (parent.depth > 0) && pathhash.has_key?(parent.name)
      pathhash[parent.name].reject { |p| MenuPath.findByName p }.each do |path|
        # logger.debug "MakeMenuPath #{path.inspect} Depth #{parent.depth}"
        mp = MenuPath.create! sport: parent.sport,
                              parent_path_id: parent.id,
                              activeGrandChildren: parent.activeGrandChildren,
                              activeChildren: parent.activeGrandChildren,
                              depth: parent.depth - 1,
                              division_id: parent.division_id,
                              name: path,
                              active: parent.activeChildren
        count = count + 1 + process_menu_path(mp, pathhash)
      end
    end
    logger.debug "processMenuPath #{parent.inspect} #{count}" if count > 0
    count
  end
end
