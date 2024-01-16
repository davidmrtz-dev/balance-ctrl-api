module Api
  module V1
    class BillingsController < ApiController
      before_action :authenticate_user!

      def index
        render json: { billings: ::Api::BillingsSerializer.json(current_user.billings) }
      end

      def create
        billing = Billing.new(billing_params.merge(user: current_user))

        if billing.save
          render json: { billing: ::Api::BillingSerializer.json(billing) }, status: :created
        else
          render json: { errors: billing.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        billing = find_billing

        if billing.update(billing_params)
          render json: { billing: ::Api::BillingSerializer.json(billing) }
        else
          render json: { errors: billing.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        billing = find_billing

        if billing.discard
          head :no_content
        else
          render json: { errors: billing.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def find_billing
        Billing.find(params[:id])
      end

      def billing_params
        params.require(:billing).permit(
          :name,
          :cycle_end_date,
          :payment_due_date,
          :billing_type,
          :credit_card_number
        )
      end
    end
  end
end
