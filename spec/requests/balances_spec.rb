require 'rails_helper'

RSpec.describe Api::BalancesController, type: :controller do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create_with_attachments(user: user) }

  describe "GET /balances/balance" do
    login_user
    it "returns no content" do
      get :balance
      byebug
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq({
        balance: balance
      }.to_json)
    end
  end
end
