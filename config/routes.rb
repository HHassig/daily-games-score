Rails.application.routes.draw do
  devise_for :users
  resources :users, param: :username
  get "up" => "rails/health#show", as: :rails_health_check

  # The leaderboard is the front page: showcase the players, not the catalog.
  root "leaderboards#index"
  resources :leaderboards, only: :index
  get "all-games" => "pages#index", as: :all_games
  get "telegram" => "pages#telegram", as: :telegram_setup
  post "telegram/link" => "pages#link_telegram", as: :link_telegram
  get "refresh" => "pages#refresh", as: :refresh_scores

  resources :games, param: :name do
    resources :results
  end
  resources :gamedays, param: :date
  resources :friendships
end
