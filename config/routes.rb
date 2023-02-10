Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'api/auth'

  namespace :api do
    defaults(format: :json) do
      get 'balance', to: 'balances#balance'
      get 'payments/current', to: 'payments#current'
      get 'payments/fixed', to: 'payments#fixed'
    end
  end
end
