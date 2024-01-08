module Api
  module V1
    class OutcomesController < ApiController
      include PaginationV1

      before_action :authenticate_user!

      def index
        outcomes = Outcome
        .with_balance_and_user
        .from_user(current_user)
        .by_transaction_date

        page = set_page
        page_size = set_page_size

        paginated = apply_pagination(
          outcomes,
          page: page,
          page_size: page_size
        )

        render json: {
          outcomes: ::Api::OutcomesSerializer.json(paginated),
          meta: meta(page, page_size, set_total_pages(outcomes.count, page_size), paginated.count)
        }
      end

      def current
        current_outcomes = current_user.current_balance.outcomes.current.by_transaction_date
        page = set_page
        page_size = set_page_size

        paginated = apply_pagination(
          current_outcomes,
          page: page,
          page_size: page_size
        )

        render json: {
          outcomes: ::Api::OutcomesSerializer.json(paginated),
          meta: meta(page, page_size, set_total_pages(current_outcomes.count, page_size), paginated.count)
        }
      end

      def search
        query_result = Query::OutcomesSearchService.new(current_user, search_params).call

        page = set_page
        page_size = set_page_size

        paginated = apply_pagination(
          query_result,
          page: page,
          page_size: page_size
        )

        render json: {
          outcomes: ::Api::OutcomesSerializer.json(paginated),
          meta: meta(page, page_size, set_total_pages(query_result.count, page_size), paginated.count)
        }
      end

      def fixed
        fixed_outcomes = current_user.current_balance.outcomes.fixed.by_transaction_date

        page = set_page
        page_size = set_page_size

        paginated = apply_pagination(
          fixed_outcomes,
          page: page,
          page_size: page_size
        )

        render json: {
          outcomes: ::Api::OutcomesSerializer.json(paginated),
          meta: meta(page, page_size, set_total_pages(fixed_outcomes.count, page_size), paginated.count)
        }
      end

      def create
        outcome =
          Outcome.new(outcome_params.merge(balance_id: current_user.current_balance&.id).except(:category_id,
                                                                                                :billing_id))

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

      def set_page
        params[:page].nil? ? 1 : params[:page].to_i
      end

      def set_page_size
        params[:page_size].nil? ? 10 : params[:page_size].to_i
      end

      def set_total_pages(count, page_size)
        (count / page_size) + ((count % page_size).positive? ? 1 : 0)
      end

      def meta(page, page_size, total_pages, total_per_page)
        {
          current_page: page,
          per_page: page_size,
          total_pages: total_pages,
          total_per_page: total_per_page
        }
      end
    end
  end
end
