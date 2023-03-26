module Api
  class BalancesController < ApiController
    before_action :authenticate_user!

    def balance
      render json: { balance: ::Api::BalanceSerializer.json(current_user.balance) }
    end
  end
end
