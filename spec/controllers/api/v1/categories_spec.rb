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

  describe 'POST /api/v1/categories' do
    let(:valid_params) do
      {
        category: {
          name: 'Food'
        }
      }
    end

    subject(:create_category) { post :create, params: valid_params }

    login_user

    it 'creates a category' do
      expect { create_category }.to change { Category.count }.by(1)

      category = Category.first

      expect(response).to have_http_status(:created)
      expect(parsed_response[:category][:id]).to eq category.id
      expect(category.name).to eq 'Food'
    end
  end
end
