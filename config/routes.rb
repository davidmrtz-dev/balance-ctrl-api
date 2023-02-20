Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'api/auth'

  namespace :api do
    defaults(format: :json) do
      get 'balance', to: 'balances#balance'
      get 'outcomes/current', to: 'outcomes#current'
      get 'outcomes/fixed', to: 'outcomes#fixed'
      resources :outcomes, only: %i[index create update destroy]
    end
  end
end
