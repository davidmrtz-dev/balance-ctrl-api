module Api
  class IncomesController < ApiController
    include Pagination

    before_action :authenticate_user!
  end
end