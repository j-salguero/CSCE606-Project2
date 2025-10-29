Rails.application.routes.draw do
  get "login",  to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "wishlist_items/index"
  get "collection_items/index"
  get "home/index"
  root "home#index"

  resources :collection_items, only: [ :index, :create, :destroy ]
  resources :wishlist_items, only: [ :index, :create, :destroy ]
  get "search", to: "search#index"
  get '/auth/discogs', to: 'sessions#authenticate', as: :oauth_start
  get '/auth/discogs/callback', to: 'sessions#callback', as: :oauth_callback
end
