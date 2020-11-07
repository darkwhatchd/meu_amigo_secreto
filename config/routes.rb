# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations' }
  mount Sidekiq::Web => '/sidekiq'

  root to: 'pages#home'
  resources :campaigns, except: [:new] do
    # Aqui inserimos o /raffle dentro da rota de Campaign
    post 'raffle', on: :member # Assim ele pega o ID antes: /campaign/:id/raffle
    # post 'raffle', on: :collection, Desta forma ele não pega o ID: /campaign/raffle
  end
  get 'members/:token/opened', to: 'members#opened'
  resources :members, only: %i[create destroy update]
end
