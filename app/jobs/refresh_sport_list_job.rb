# frozen_string_literal: true

#
# $Id$
#
class RefreshSportListJob < BetfairJob
  queue_priority PRIORITY_REFRESH_SPORT_LIST

  def perform
    # Lots of MenuPath updates done 24th Sep 2016 - need to avoid triggering the world
    # menu_path_updates_time = Time.new 2016, 9, 24, 18, 20
    # normal_cutoff_time = Time.now - 1.month
    # cutoff_time = menu_path_updates_time > normal_cutoff_time ? menu_path_updates_time : normal_cutoff_time

    bc.getActiveEventTypes.each do |event_type|
      sport = Sport.find_or_create_by!(name: event_type.name, betfair_sports_id: event_type.id)
      if sport.active
        sport.top_menu_paths.each do |menu_path|
          MakeMenuPathsJob.perform_later menu_path
        end
        # # sport.menu_paths.where('depth > 0 and updated_at > ?', cutoff_time).order('updated_at desc').collect { |mp| mp.parent_path }.reject { |m| m.nil? }.uniq.each do |parent|
        # # ignore 'active' non-zero depths as these are probably actual matches...
        # sport.menu_paths.where.not(depth: 0).where.not(active: true).order('updated_at desc').map { |mp| mp.parent_path }.compact.uniq.each do |parent|
        #   MakeMenuPathsJob.perform_later parent
        # end
        # as we're triggering the parent, only pick out paths that have resulted in matches before or non-zero depth
        interesting_menu_paths = sport.menu_paths.order(updated_at: :desc)
        (interesting_menu_paths.active + interesting_menu_paths.where.not(depth: 0)).map { |mp| mp.parent_path }.compact.uniq.each do |parent|
          MakeMenuPathsJob.perform_later parent
        end
      end
    end
  end
end
