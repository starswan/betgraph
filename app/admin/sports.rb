ActiveAdmin.register Sport do
  config.sort_order = "betfair_events_count_desc"

  permit_params :name, :betfair_sports_id, :expiry_time_in_minutes, :active
end
