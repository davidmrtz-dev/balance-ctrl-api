require 'rails_helper'

RSpec.describe Api::V1::PaymentsController, type: :controller do
  let(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let(:balance) { BalanceFactory.create_with_attachments(user: user) }
  let!(:outcome) { OutcomeFactory.create(balance: balance) }

  describe 'GET /api/v1/payments/applied' do
    login_user

    it 'return paginated outcomes' do
      get :applied, params: { balance_id: balance.id }

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:payments].pluck(:id)).to match_array(balance.outcomes_applied_payments.ids)
    end
  end

  describe 'GET /api/v1/payments/pending' do
    login_user

    before do
      outcome.payments.first.pending!
    end

    it 'return paginated outcomes' do
      get :pending

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:payments].pluck(:id)).to match_array(Payment.pending.ids)
    end
  end

  describe 'PUT /api/v1/payments/:id' do
    login_user

    before do
      BalancePayment.create!(balance: balance, payment: outcome.payments.first)
    end

    it 'updates payment status' do
      put :update, params: { id: outcome.payments.first.id, payment: { status: 'applied' } }

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:payment][:status]).to eq('applied')
      expect(outcome.payments.first.reload.applied?).to be_truthy
    end
  end
end
