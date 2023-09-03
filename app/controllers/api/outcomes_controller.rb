module Api
  class OutcomesController < ApiController
    include Pagination

    before_action :authenticate_user!

    def index
      outcomes = Outcome
        .with_balance_and_user
        .from_user(current_user)
        .by_transaction_date

      page = paginate(
        outcomes,
        limit: params[:limit],
        offset: params[:offset]
      )

      render json: {
        outcomes: ::Api::OutcomesSerializer.json(page)
      }
    end

    def current
      current_outcomes = Outcome
        .with_balance_and_user
        .from_user(current_user)
        .current_types.by_transaction_date

      current_page = paginate(
        current_outcomes,
        limit: params[:limit],
        offset: params[:offset]
      )

      render json: {
        outcomes: ::Api::OutcomesSerializer.json(current_page),
        total_pages: total_pages(current_outcomes.count)
      }
    end

    def search
      balance = current_user.balance
      query_result = Query::OutcomesSearchService.new(balance, search_params).call

      query_page = paginate(
        query_result,
        limit: params[:limit],
        offset: params[:offset]
      )

      render json: {
        outcomes: ::Api::OutcomesSerializer.json(query_page),
        total_pages: total_pages(query_result.count)
      }
    end

    def fixed
      fixed_outcomes = Outcome
        .with_balance_and_user
        .from_user(current_user)
        .fixed_types.by_transaction_date

      fixed_page = paginate(
        fixed_outcomes,
        limit: params[:limit],
        offset: params[:offset]
      )

      render json: {
        outcomes: ::Api::OutcomesSerializer.json(fixed_page),
        total_pages: total_pages(fixed_outcomes.count)
      }
    end

    def create
      outcome =
        Outcome.new(outcome_params.merge(balance_id: current_user.balance_id))

      if outcome.save
        render json: { outcome: ::Api::OutcomeSerializer.json(outcome) }, status: :created
      else
        render json: { errors: outcome.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      outcome = find_outcome

      if outcome.update(outcome_params)
        outcome.update_category(params[:category_id]) if params[:category_id].present?

        render json: { outcome: ::Api::OutcomeSerializer.json(outcome) }
      else
        render json: { errors: outcome.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      outcome = find_outcome

      if outcome.current? && outcome.destroy!
        head :no_content
      else
        render json: { errors: 'Can not delete a fixed outcome '}, status: :unprocessable_entity
      end
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
        :transaction_date,
        :quotas
      )
    end

    def search_params
      params.permit(
        :keyword,
        :start_date,
        :end_date
      )
    end

    def total_pages(count)
      total_pages = count / 5
      (count % 5).positive? ? total_pages + 1 : total_pages
    end
  end
end
