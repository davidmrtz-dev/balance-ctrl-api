module Api
  module V1
    class BillingsController < ApiController
      before_action :authenticate_user!

      def index
        render json: { billings: current_user.billings }
      end
    end
  end
end
