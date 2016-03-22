Rails.application.routes.draw do
  resources :users
  resources :products
  
  root 'index#index'
end
