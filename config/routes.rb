Rails.application.routes.draw do
  resources :users
  resources :products
  resources :admin
  
  
  root 'index#index'

  get 'index' => 'index#index', as: :index

end
