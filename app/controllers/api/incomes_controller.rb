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
        render json: { income: ::Api::IncomeSerializer.json(income) }, status: :created
      else
        render json: { errors: income.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      income = find_income

      if income.update(income_params)
        render json: { income: ::Api::IncomeSerializer.json(income) }
      else
        render json: { errors: income.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      find_income.destroy!

      head :no_content
    end

    private

    def find_income
      Income.find(params[:id])
    end

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