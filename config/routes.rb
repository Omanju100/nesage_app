Rails.application.routes.draw do
  resources :settings, only: [:index, :update, :show, :destroy]
  root to: 'settings#index'
  delete '/settings/:id', to: 'settings#destroy', as: 'delete_setting'
  patch '/settings', to: 'settings#update'
end
