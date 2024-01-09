require 'rails_helper'

RSpec.describe Api::V1::BillingsController, type: :controller do
  let(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }

  describe 'GET /api/v1/billings' do
    let!(:billing) { BillingFactory.create(user: user) }

    login_user

    it 'returns billings data' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:billings].pluck(:id)).to match_array(Billing.ids)
    end
  end

  describe 'POST /api/v1/billings' do
    login_user

    it 'creates billing' do
      post :create, params: {
        billing: {
          name: 'Credit Card',
          cycle_end_date: Time.zone.now,
          payment_due_date: Time.zone.now,
          billing_type: 'credit'
        }
      }

      expect(response).to have_http_status(:created)
      expect(parsed_response[:billing][:name]).to eq('Credit Card')
    end
  end

  describe 'PUT /api/v1/billings/:id' do
    let!(:billing) { BillingFactory.create(user: user) }

    login_user

    it 'updates billing' do
      put :update, params: {
        id: billing.id,
        billing: {
          name: 'Credit Card',
          cycle_end_date: Time.zone.now,
          payment_due_date: Time.zone.now,
          billing_type: 'credit'
        }
      }

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:billing][:name]).to eq('Credit Card')
    end
  end

  describe 'DELETE /api/v1/billings/:id' do
    let!(:billing) { BillingFactory.create(user: user) }

    login_user

    it 'discard billing' do
      delete :destroy, params: {
        id: billing.id
      }

      expect(response).to have_http_status(:no_content)
      expect(billing.reload.discarded?).to be_truthy
    end
  end
end
