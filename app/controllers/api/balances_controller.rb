module Api
  class BalancesController < ApiController
    before_action :authenticate_user!

    def balance
      balance = current_user.balance
      render json: { balance: ::Api::BalanceSerializer.json(balance) }
    end
  end
end