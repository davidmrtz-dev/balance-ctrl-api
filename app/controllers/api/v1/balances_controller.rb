module Api
  module V1
    class BalancesController < ApiController
      before_action :authenticate_user!

      def index
        balances = current_user.balances.first(12)

        render json: { balances: ::Api::BalancesSerializer.json(balances) }
      end

      def show
        balance = current_user.balances.find(params[:id])

        render json: { balance: ::Api::BalanceSerializer.json(balance) }
      end

      def balance
        balance = current_user.current_balance

        render json: { balance: ::Api::BalanceSerializer.json(balance) }
      end
    end
  end
end
