Rails.application.routes.draw do
  resources :facilities
  defaults format: :json do
    devise_for :users, path: "user", path_names: {
      sign_in: "login",
      sign_out: "logout"
    },
    controllers: {
      sessions: "users/sessions",
      registrations: "users/registrations",
      passwords: "users/passwords"
    }

    namespace :users do
      get "me/permissions", to: "permissions#show"
    end

    resources :condominia do
      resources :notices, only: [:index]
      resources :employees, only: [:index, :create]
      resources :apartments, only: [:index, :create]
    end
    resources :apartments, only: [:show, :update, :destroy] do
      patch :approve, on: :member
      resources :notices, only: [:index, :create]
      resources :residents, only: [:create, :update, :destroy]
    end
    resources :residents, only: [:show]
    resources :notices, only: [:show, :update, :destroy]
    resources :users, only: [:show, :update, :create]
    resources :employees, only: [:show, :update, :destroy]
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
