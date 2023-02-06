Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'api/auth'

  namespace :api do
    defaults(format: :json) do
      get 'balances/balance', to: 'balances#balance'
      resources :payments
    end
  end
end
