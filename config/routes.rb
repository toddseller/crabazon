Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
  resources :users
  resources :products
  resources :admin
  resources :categories
  resources :orders

  
      post 'carts/:product_id', to: 'carts#add', as: :add_to
      post 'carts', to: 'carts#update_cart', as: :update_to
      delete 'carts/:product_id', to: 'carts#remove', as: :remove_from
 

  root 'index#index'

  get 'index' => 'index#index', as: :index
end
