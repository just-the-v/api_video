# frozen_string_literal: true

Rails.application.routes.draw do
  scope format: 'json' do
    resources :users, only: %i[create destroy update show], path: 'user' do
      resources :videos, only: %i[create], path: 'video'
      member do
        get '/videos', to: 'videos#show_by_user'
      end
    end
    get '/users', to: 'users#index'

    resources :videos, only: %i[index]
    resources :videos, only: %i[destroy], path: 'video' do
      resources :comments, only: %i[create], path: 'comment'
      resources :comments, only: %i[index]
    end
    patch '/video/:id', to: 'videos#encode'
    put '/video/:id', to: 'videos#update'

    resources :auth, only: [:create]
  end
  match '*abatartufume', to: 'application#render_not_found', via: :all
end
