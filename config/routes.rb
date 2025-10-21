Rails.application.routes.draw do
  get "search/index"
  get "wishlist_items/index"
  get "collection_items/index"
  get "home/index"
  root "home#index"
  resources :collection_items, only: [ :index, :create, :destroy ]
  resources :wishlist_items, only: [ :index, :create, :destroy ]
  get "search", to: "search#index"
end
