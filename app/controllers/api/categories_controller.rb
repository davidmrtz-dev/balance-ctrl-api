module Api
  class CategoriesController < ApiController
    before_action :authenticate_user!

    def index
      categories = Category.all
      render json: { categories: categories }
    end
  end
end
