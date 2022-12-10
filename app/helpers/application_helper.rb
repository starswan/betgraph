# frozen_string_literal: true

#
# $Id$
#
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def swap_direction(direction)
    direction == "asc" ? "desc" : "asc"
  end

  def dayoftheweek(thetime)
    thetime.strftime("%a")
  end

  def thedate(thetime)
    thetime.strftime("%d-%b-%Y")
  end

  def thetime(time)
    time.strftime("%H:%M")
  end
  LINKS = { events: "Events",
            sports: "Sports",
            football_divisions: "Football Divisions",
            seasons: "Football Seasons",
            betfair_runner_types: "Runner Types" }.freeze
  def menu_item(link)
    ('<div class="menu_item">' + link + "</div>\n").html_safe
  end

  def link_for(symbol)
    menu_item link_to(LINKS[symbol], controller: symbol)
  end

  def menu_to(*args)
    menu_item link_to(*args)
  end

  def links_for(*args)
    link_join raw_links_for(*args)
  end

  def raw_links_for(*args)
    args.collect { |l| link_for(l) }
  end

  def just_links_for(*args)
    args.collect { |symbol| link_to(LINKS[symbol], controller: symbol) }
  end

  def link_join(linklist)
    ('<div class="menu">' + "\n" + linklist.join("") + "</div>\n").html_safe
  end

  def sport_links
    @active_sports.map do |sport|
      menu_item link_to(sport.name, sport)
    end
  end

  def active_current_links
    [menu_to("Active", controller: :matches, action: :active), menu_to("Future", controller: :matches, action: :future)]
  end

  def links_for_sport(sport)
    [menu_to(sport.name.to_s, sport),
     menu_to("Menu Paths", sport_menu_paths_path(sport)),
     menu_to("Market Types", sport_betfair_market_types_path(sport)),
     menu_to("Divisions", sport_divisions_path(sport)),
     menu_to("Basket Rules", sport_basket_rules_path(sport))]
  end

private

  def all_sport_links
    link_join sport_links
  end
end
