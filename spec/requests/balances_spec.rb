require 'rails_helper'

RSpec.describe Api::BalancesController, type: :controller do
  describe "GET /balances/balance" do
    login_user

    it "returns no content" do
      balance = Balance.create!(user: User.last)
      get :balance

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq({
        balance: balance
      }.to_json)
    end
  end
end
