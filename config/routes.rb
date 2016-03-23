Rails.application.routes.draw do
  devise_for :users
  resources :users
  resources :products
  resources :admin

  root 'index#index'

  get 'index' => 'index#index', as: :index

end
