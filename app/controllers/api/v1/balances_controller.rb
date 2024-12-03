module Api
  module V1
    class BalancesController < ApiController
      before_action :authenticate_user!, except: :webhook

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

      def webhook
        Rails.logger.info "Webhook received: #{params.inspect}"

        render json: { message: 'Webhook received', params: params }

        # render json: { errors: 'Unauthorized' }, status: :unauthorized
      end
    end
  end
end
