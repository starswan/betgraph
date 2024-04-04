Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  ActiveAdmin.routes(self)

  get "match_teams/index"

  resources :sports, only: [:show] do
    resources :basket_rules
    resources :betfair_market_types, only: [:index, :show, :edit, :update, :destroy]
    resources :divisions
    resources :teams
    resources :matches, only: :index, controller: "sports/matches"

    resources :seasons, only: [:index, :show] do
      get "threshold/:threshold" => "seasons#show"
      resources :soccer_matches

      resources :divisions, only: [] do
        resources :fixtures, only: [:index, :show], controller: "divisions/fixtures" do
          resources :bet_markets, only: [:index], controller: "divisions/bet_markets" do
            get :half_time, on: :collection
          end
        end
      end
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
    resources :seasons, only: [] do
      resources :tables, only: [:index, :show]
    end
    resources :matches, only: [:index]
    resources :soccer_matches, only: [:index, :edit]
    resources :tennis_matches, only: []
  end

  resources :matches, except: [:create, :new] do
    collection do
      get :future
      get :active
    end
    resources :results
    resources :bet_markets, only: %i[index]
    resources :baskets, except: [:edit]
    resources :match_teams
  end
  resources :soccer_matches, only: [:show, :update, :destroy, :edit] do
    resources :scorers, except: :show, controller: "soccer_matches/scorers"
    resources :results
    resources :bet_markets, only: :index, controller: "soccer_matches/bet_markets" do
      get :half_time, on: :collection
    end
    resources :baskets, only: [:index, :destroy], controller: "soccer_matches/baskets"
    resources :teams
  end
  resources :tennis_matches, only: [:index, :show]
  resources :motor_races, only: [] do
    resources :bet_markets, only: %i[index]
  end

  resources :scorers
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

  resources :bet_markets, only: %i[show edit update destroy] do
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

  # root path
  get "/" => "matches#future"
end
