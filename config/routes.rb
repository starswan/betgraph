Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  ActiveAdmin.routes(self)

  get "match_teams/index"

  resources :sports, except: [:new, :create] do
    resources :basket_rules
    resources :betfair_market_types, only: [:index, :show, :edit, :update, :destroy]
    resources :divisions
    resources :teams
    resources :matches, only: :index, controller: "sports/matches"

    resources :seasons, only: [:index, :show] do
      get "threshold/:threshold" => "seasons#show"
      resources :soccer_matches
    end
  end
  resources :calendars, only: [] do
    resources :seasons, only: [:new, :destroy, :edit, :create, :update]
  end

  resources :teams do
    resources :team_names, except: [:update]
    resources :team_totals
  end
  resources :team_names, only: [:update]

  resources :results
  resources :divisions do
    resources :matches
    resources :soccer_matches
    resources :tennis_matches
    resources :motor_races
    resources :snooker_matches
  end

  resources :matches do
    collection do
      get :future
      get :active
    end
    resources :scorers
    resources :results
    resources :bet_markets
    resources :baskets, except: [:edit]
    resources :match_teams
  end
  resources :soccer_matches do
    resources :scorers
    resources :results
    resources :bet_markets, only: :index, controller: "soccer_matches/bet_markets" do
      get :half_time, on: :collection
    end
    resources :baskets, only: [:index, :destroy], controller: "soccer_matches/baskets"
    resources :teams
  end
  resources :tennis_matches do
  end
  resources :motor_races do
    resources :bet_markets
  end
  resources :snooker_matches do
  end

  resources :scorers
  resources :positions
  resources :baskets do
    resources :basket_items
    resources :event_basket_prices
  end
  resources :basket_rules do
    resources :basket_rule_items
  end
  resources :basket_rule_items
  resources :football_divisions
  resources :betfair_market_types do
    resources :betfair_runner_types
  end
  resources :betfair_runner_types
  resources :team_total_configs
  resources :market_prices
  resources :event_basket_prices

  resources :bet_markets do
    resources :market_runners
    resources :trades, controller: "bet_markets/trades"
    resources :market_prices, controller: "bet_markets/market_prices"
  end
  resources :market_runners do
    resources :trades
    resources :market_prices
  end
  resources :trades
  resources :basket_items
  resources :market_price_times

  get "/" => "matches#future"
  # get '/:controller(/:action(/:id))'
end
