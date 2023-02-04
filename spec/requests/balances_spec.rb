require 'rails_helper'

RSpec.describe Api::BalancesController, type: :controller do
  describe "GET /balances/balance" do
    login_user

    it "returns no content" do
      get :balance
      expect(response).to have_http_status(:no_content)
    end
  end
end
