Rails.application.routes.draw do
  resources :settings
  devise_for :users
  root to: 'pages#home', as: :home
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # get 'about', to: 'pages#about', as: :about
  get 'purchases', to: 'purchases#index', as: :purchases
  get 'purchase1', to: 'purchases#purchase1', as: :purchase1
  get 'purchase2', to: 'purchases#purchase2', as: :purchase2
  get 'purchase3', to: 'purchases#purchase3', as: :purchase3
  get 'purchase4', to: 'purchases#purchase4', as: :purchase4
  get 'purchase5', to: 'purchases#purchase5', as: :purchase5
  get 'purchase6', to: 'purchases#purchase6', as: :purchase6
  get 'search', to: 'searches#index', as: :searches
  # get 'settings', to: 'settings#index', as: :settings
  # get 'settings/edit', to: 'settings#edit', as: :edit_settings
  # patch 'settings', to: 'settings#update'
  # Sidekiq Web UI, only for admins.
  require 'sidekiq/web'
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq', as: :sidekiq
  end
end
