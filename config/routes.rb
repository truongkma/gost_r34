Rails.application.routes.draw do
  resources :gosts, only: [:show, :update]
end
