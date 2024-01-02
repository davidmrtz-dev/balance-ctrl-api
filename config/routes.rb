Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'api/v1/auth'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'balance', to: 'balances#balance'
      get 'billings', to: 'billings#index'
      resources :outcomes, only: %i[index create update destroy] do
        collection do
          get 'current', to: 'outcomes#current'
          get 'fixed', to: 'outcomes#fixed'
          get :search
        end
      end
      resources :payments, only: [] do
        collection do
          get 'applied', to: 'payments#applied'
          get 'pending', to: 'payments#pending'
        end
      end
      resources :incomes, only: %i[index create update destroy]
      resources :categories, only: %i[index create update destroy]
    end
  end
end
