module Api
  module V1
    class CategoriesController < ApiController
      before_action :authenticate_user!

      def index
        render json: { categories: ::Api::CategoriesSerializer.json(Category.all) }
      end
    end
  end
end
