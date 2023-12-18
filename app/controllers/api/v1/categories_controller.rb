module Api
  module V1
    class CategoriesController < ApiController
      before_action :authenticate_user!

      def index
        render json: { categories: ::Api::CategoriesSerializer.json(Category.all) }
      end

      def create
        category =
          Category.new(category_params)

        if category.save
          render json: { category: ::Api::CategorySerializer.json(category) }, status: :created
        else
          render json: { errors: category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def category_params
        params.require(:category).permit(
          :name
        )
      end
    end
  end
end
