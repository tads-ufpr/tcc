Rails.application.routes.draw do
  resources :notices
  devise_for :users, path: "user", path_names: {
    sign_in: "login",
    sign_out: "logout"
  },
  controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }

  resources :condominia
  resources :apartments
  resources :users, only: [:show, :update, :create]

  get "up" => "rails/health#show", as: :rails_health_check
end
