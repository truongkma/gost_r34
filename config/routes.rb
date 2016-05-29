Rails.application.routes.draw do
  root to: "gosts#show", id: "1"
  resources :gosts, only: [:show, :update]
end
