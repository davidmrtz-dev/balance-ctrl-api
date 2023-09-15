require 'rails_helper'

RSpec.describe Api::V1::BillingsController, type: :controller do
  let(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:billing) { BillingFactory.create(user: user) }

  describe 'GET /api/v1/billings' do
    login_user

    it 'returns billings data' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:billings].pluck(:id)).to match_array(Billing.ids)
    end
  end
end
