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

    def create
      income =
        Income.new(income_params.merge(balance_id: current_user.balance_id))

      if income.save
        head :no_content
      else
        render json: { errors: income.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def income_params
      params.require(:income).permit(
        :transaction_type,
        :amount,
        :description,
        :frequency
      )
    end
  end
end