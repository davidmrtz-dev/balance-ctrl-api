module Api
  class BalancesController < ApiController
    before_action :authenticate_user!

    def balance
      head :no_content
    end
  end
end