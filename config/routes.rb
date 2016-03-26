Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
  resources :users
  resources :products
  resources :admin
  resources :categories
  
  post 'carts/:product_id', to: 'carts#add', as: :add_to
  	# put 'remove/:product_id', to: 'carts#remove', as: :remove_from

  root 'index#index'

  get 'index' => 'index#index', as: :index
end
