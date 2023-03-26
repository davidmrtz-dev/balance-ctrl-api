require 'rails_helper'

RSpec.describe Api::BalancesController, type: :controller do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create_with_attachments(user: user) }

  describe 'GET /balances/balance' do
    login_user

    it 'returns balance data' do
      get :balance

      expect(response).to have_http_status(:ok)
      expect(parsed_response)
        .to match({ balance: Api::BalanceSerializer.json(balance.reload) }.as_json)
    end
  end
end
