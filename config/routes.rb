Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'api/auth'

  get 'balances', to: 'balances#index'
end
