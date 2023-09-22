Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'api/v1/auth'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'balance', to: 'balances#balance'
      get 'categories', to: 'categories#index'
      get 'billings', to: 'billings#index'
      resources :outcomes, only: %i[index create update destroy] do
        collection do
          get 'current', to: 'outcomes#current'
          get 'fixed', to: 'outcomes#fixed'
          get :search
        end
      end
      resources :incomes, only: %i[index create update destroy]
    end
  end
end
