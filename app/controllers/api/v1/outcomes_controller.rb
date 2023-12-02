module Api
  module V1
    class OutcomesController < ApiController
      include Pagination
      include PaginationV1

      before_action :authenticate_user!

      # rubocop:disable Metrics/AbcSize
      def index
        outcomes = Outcome
          .with_balance_and_user
          .from_user(current_user)
          .by_transaction_date

        page = params[:page].nil? ? 1 : params[:page].to_i
        page_size = params[:page_size].nil? ? 10 : params[:page_size].to_i

        paginated = apply_pagination(
          outcomes,
          page: page,
          page_size: page_size
        )

        render json: {
          outcomes: ::Api::OutcomesSerializer.json(paginated),
          meta: {
            current_page: page,
            per_page: page_size,
            total_pages: (outcomes.count / page_size) + ((outcomes.count % page_size).positive? ? 1 : 0),
            total_per_page: paginated.count
          }
        }
      end
      # rubocop:enable Metrics/AbcSize

      def current
        current_outcomes = Outcome
          .with_balance_and_user
          .from_user(current_user)
          .current.by_transaction_date

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
          .fixed.by_transaction_date

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
          Outcome.new(outcome_params.merge(balance_id: current_user.balance_id).except(:category_id, :billing_id))

        if outcome.save
          assign_category(outcome)

          assign_billing(outcome)

          render json: { outcome: ::Api::OutcomeSerializer.json(outcome) }, status: :created
        else
          render json: { errors: outcome.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        outcome = find_outcome

        if outcome.update(outcome_params)
          render json: { outcome: ::Api::OutcomeSerializer.json(outcome) }
        else
          render json: { errors: outcome.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        outcome = find_outcome

        if outcome.discard!
          head :no_content
        else
          render json: { errors: 'Can not delete a fixed outcome ' }, status: :unprocessable_entity
        end
      end

      private

      def assign_category(outcome)
        return if outcome_params[:category_id].blank?

        Categorization.create!(category_id: outcome_params[:category_id], transaction_id: outcome.id)
      end

      def assign_billing(outcome)
        return if outcome_params[:billing_id].blank?

        BillingTransaction.create!(billing_id: outcome_params[:billing_id], transaction_id: outcome.id)
      end

      def find_outcome
        Outcome.find(params[:id])
      end

      def outcome_params
        params.require(:outcome).permit(
          :transaction_type,
          :amount,
          :description,
          :transaction_date,
          :quotas,
          :category_id,
          :billing_id,
          categorizations_attributes: %i[category_id],
          billing_transactions_attributes: %i[billing_id]
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
end
