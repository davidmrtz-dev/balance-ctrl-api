module Api
  class OutcomesController < ApiController
    include Pagination

    before_action :authenticate_user!

    def current
      current_outcomes = Outcome.
        with_balance_and_user.
          from_user(current_user).
            current_types.by_purchase_date

      current_page = paginate(
        current_outcomes,
        limit: params[:limit],
        offset: params[:offset]
      )

      render json: {
        outcomes: current_page,
        total_pages: total_pages(current_outcomes.count)
      }
    end

    def fixed
      fixed_outcomes = Outcome.
        with_balance_and_user.
          from_user(current_user).
            fixed_types.by_purchase_date

      fixed_page = paginate(
        fixed_outcomes,
        limit: params[:limit],
        offset: params[:offset]
      )

      render json: {
        outcomes: fixed_page,
        total_pages: total_pages(fixed_outcomes.count)
      }
    end

    def create
      outcome =
        Outcome.new(outcome_params.merge(balance_id: current_user.balance.id))

      if outcome.save
        render json: { outcome: outcome }, status: :created
      else
        render json: { errors: outcome.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      outcome = find_outcome

      if outcome.update(outcome_params)
        render json: { outcome: outcome }, status: :ok
      else
        render json: { errors: outcome.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      find_outcome.destroy!

      head :no_content
    end

    private

    def find_outcome
      Outcome.find(params[:id])
    end

    def outcome_params
      params.require(:outcome).permit(
        :transaction_type,
        :amount,
        :description,
        :purchase_date,
        :quotas
      )
    end

    def total_pages(count)
      total_pages = count / 5
      count % 5 > 0 ? total_pages + 1 : total_pages
    end
  end
end
