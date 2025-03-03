Rails.application.routes.draw do
  devise_for :users
  resources :users, param: :username
  get "up" => "rails/health#show", as: :rails_health_check
  root "pages#index"
  resources :games, param: :name do
    resources :results
  end
  resources :gamedays, param: :date
  resources :friendships
end
