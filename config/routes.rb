Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  root "posts#index"

  resources :posts, only: [:index, :show, :create] do
    resources :reactions, only: [:create]
  end

  resources :rankings, only: [:index]

  get "up" => "rails/health#show", as: :rails_health_check
end
