module Api
  class PaymentsController < ApiController
    include Pagination

    before_action :authenticate_user!

    def current
      current = current_user.balance.payments_current
      current_page = paginate(
        current,
        limit: params[:limit],
        offset: params[:offset]
      )
      current_total_pages = current.count / 5

      render json: {
        current: current_page,
        current_total_pages: current.count % 5 > 0 ? current_total_pages + 1 : current_total_pages
      }
    end

    def fixed
      fixed = current_user.balance.payments_fixed
      fixed_page = paginate(
        fixed,
        limit: params[:limit],
        offset: params[:offset]
      )
      fixed_total_pages = fixed.count / 5

      render json: {
        fixed: fixed_page,
        fixed_total_pages: fixed.count % 5 > 0 ? fixed_total_pages + 1 : fixed_total_pages
      }
    end
  end
end
