Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'api/v1/auth'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'balance', to: 'balances#balance'
      resources :outcomes, only: %i[index create update destroy] do
        collection do
          get 'current', to: 'outcomes#current'
          get 'fixed', to: 'outcomes#fixed'
          get :search
        end
      end
      resources :payments, only: %i[update] do
        collection do
          get 'applied', to: 'payments#applied'
          get 'pending', to: 'payments#pending'
        end
      end
      resources :incomes, only: %i[index create update destroy]
      resources :categories, only: %i[index create update destroy]
      resources :balances, only: %i[index show]
      resources :billings, only: %i[index create update destroy]
    end
  end

  mount Flipper::UI.app(Flipper) => 'admin/flipper', as: 'flipper_ui'
end
