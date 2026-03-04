Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  root "posts#index"

  resources :posts, only: [:index, :show, :create] do
    resources :reactions, only: [:create]
    resources :comments,  only: [:create]
  end

  resources :rankings, only: [:index]

  resources :users, only: [:show] do
    resource :follow, only: [:create, :destroy]
  end

  get    "profile",      to: "users#show",   as: :profile
  get    "profile/edit", to: "users#edit",   as: :edit_profile
  patch  "profile",      to: "users#update"

  get "up" => "rails/health#show", as: :rails_health_check
end
