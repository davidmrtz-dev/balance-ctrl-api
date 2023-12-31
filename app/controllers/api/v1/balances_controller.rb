module Api
  module V1
    class BalancesController < ApiController
      before_action :authenticate_user!

      def balance
        render json: { balance: ::Api::BalanceSerializer.json(current_user.current_balance) }
      end
    end
  end
end
