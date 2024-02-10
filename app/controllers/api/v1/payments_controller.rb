module Api
  module V1
    class PaymentsController < ApiController
      include PaginationV1

      before_action :authenticate_user!

      def applied
        payments = current_user.balances.find(params[:balance_id]).outcomes_applied_payments

        page = set_page
        page_size = set_page_size

        paginated = apply_pagination(
          payments,
          page: page,
          page_size: page_size
        )

        render json: {
          payments: ::Api::PaymentsSerializer.json(paginated),
          meta: {
            current_page: page,
            per_page: page_size,
            total_pages: set_total_pages(payments.count, page_size),
            total_per_page: paginated.count
          }
        }
      end

      def pending
        payments = current_user.current_balance.payments.pending

        page = set_page
        page_size = set_page_size

        paginated = apply_pagination(
          payments,
          page: page,
          page_size: page_size
        )

        render json: {
          payments: ::Api::PaymentsSerializer.json(paginated),
          meta: {
            current_page: page,
            per_page: page_size,
            total_pages: set_total_pages(payments.count, page_size),
            total_per_page: paginated.count
          }
        }
      end

      def update
        payment = find_payment

        if payment.update(payment_params)
          render json: { payment: ::Api::PaymentSerializer.json(payment) }
        else
          render json: { errors: payment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def find_payment
        Payment.find(params[:id])
      end

      def payment_params
        params.require(:payment).permit(:status, :paid_at)
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
    end
  end
end
