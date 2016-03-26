Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
  resources :users
  resources :products
  resources :admin
  resources :categories
  resources :cart
  

  root 'index#index'

  get 'index' => 'index#index', as: :index
end
