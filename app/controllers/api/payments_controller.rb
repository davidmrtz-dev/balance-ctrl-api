module Api
  class PaymentsController < ApiController
    before_action :authenticate_user!

    def index
      current = current_user.balance.payemnts_current
      fixed = current_user.balance.payments_fixed
      render json: {
        current: current,
        fixed: fixed
      }
    end
  end
end
