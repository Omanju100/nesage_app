Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :settings, only: [:index, :update, :show, :destroy]
  root to: 'settings#index'
  delete '/settings/:id', to: 'settings#destroy', as: 'delete_setting'
  patch '/settings', to: 'settings#update'
  post '/login', to: 'sessions#create', as: :login
end
