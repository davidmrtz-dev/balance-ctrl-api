module Api
  class PaymentsController < ApiController
    include Pagination

    before_action :authenticate_user!

    def current
      current_outcomes =
        Outcome.with_balance.from_user(current_user).current

      current_page = paginate(
        current_outcomes,
        limit: params[:limit],
        offset: params[:offset]
      )

      render json: {
        payments: current_page,
        total_pages: total_pages(current_outcomes.count)
      }
    end

    def fixed
      fixed = current_user.balance.outcomes
      fixed_page = paginate(
        fixed,
        limit: params[:limit],
        offset: params[:offset]
      )

      render json: {
        payments: fixed_page,
        total_pages: total_pages(fixed.count)
      }
    end

    private

    def total_pages(count)
      total_pages = count / 5
      count % 5 > 0 ? total_pages + 1 : total_pages
    end
  end
end
