require 'rails_helper'

RSpec.describe Api::IncomesController, type: :controller do
  xdescribe 'GET /api/incomes' do
    login_user

    it 'returns paginated incomes' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:incomes].map { |i| i[:id] }).to match_array(Income.ids)
    end
  end
end