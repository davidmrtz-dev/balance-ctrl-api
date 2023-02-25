module Api
  class IncomesController < ApiController
    include Pagination

    before_action :authenticate_user!

    def index
      incomes = Income.
        with_balance_and_user.
          from_user(current_user)

      page = paginate(
        incomes,
        limit: params[:limit],
        offset: params[:offset]
      )

      render json: {
        incomes: ::Api::IncomesSerializer.json(page)
      }
    end
  end
end