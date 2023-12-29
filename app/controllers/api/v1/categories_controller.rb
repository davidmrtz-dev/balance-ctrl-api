module Api
  module V1
    class CategoriesController < ApiController
      before_action :authenticate_user!

      def index
        render json: { categories: ::Api::CategoriesSerializer.json(Category.kept) }
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

      def update
        category = find_category

        if category.update(category_params)
          render json: { category: ::Api::CategorySerializer.json(category) }
        else
          render json: { errors: category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        category = find_category

        category.discard!

        head :no_content
      end

      private

      def find_category
        Category.find(params[:id])
      end

      def category_params
        params.require(:category).permit(
          :name
        )
      end
    end
  end
end
