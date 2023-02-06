module Api
  class PaymentsController < ApiController
    include Pagination

    before_action :authenticate_user!

    def index
      current = current_user.balance.payments_current
      current_page = paginate(
        current,
        limit: params[:limit],
        offset: params[:offset]
      )
      fixed = current_user.balance.payments_fixed
      fixed_page = paginate(
        fixed,
        limit: params[:limit],
        offset: params[:offset]
      )

      render json: {
        current: current_page,
        fixed: fixed_page,
        total_current: current_page.count,
        total_fixed: fixed_page.count
      }
    end
  end
end
