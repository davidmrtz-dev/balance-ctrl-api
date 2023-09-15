require 'rails_helper'

RSpec.describe Api::V1::CategoriesController, type: :controller do
  let!(:category) { CategoryFactory.create }

  describe 'GET /api/v1/categories' do
    login_user

    it 'return paginated outcomes' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:categories].pluck(:id)).to match_array(Category.ids)
    end
  end
end
