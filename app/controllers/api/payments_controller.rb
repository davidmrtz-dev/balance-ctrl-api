module Api
  class PaymentsController < ApiController
    include Pagination

    before_action :authenticate_user!

    def current
      current_outcomes = Outcome.
        with_balance_and_user.
          from_user(current_user).current_types

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
      fixed_outcomes = Outcome.
        with_balance_and_user.
          from_user(current_user).fixed_types

      fixed_page = paginate(
        fixed_outcomes,
        limit: params[:limit],
        offset: params[:offset]
      )

      render json: {
        payments: fixed_page,
        total_pages: total_pages(fixed_outcomes.count)
      }
    end

    private

    def total_pages(count)
      total_pages = count / 5
      count % 5 > 0 ? total_pages + 1 : total_pages
    end
  end
end
