module Api
  class PaymentsController < ApiController
    before_action :authenticate_user!

    def index
      head :ok
    end
  end
end
