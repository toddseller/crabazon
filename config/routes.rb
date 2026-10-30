Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations', passwords: 'users/passwords' }
  devise_scope :user do
    get 'users/password/sent', to: 'users/passwords#sent', as: :user_password_sent
  end
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
