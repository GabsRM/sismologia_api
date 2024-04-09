Rails.application.routes.draw do
  namespace :api do
    resources :features, only: [:index]
  end
end
