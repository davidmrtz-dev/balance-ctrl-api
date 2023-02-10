require 'rails_helper'

RSpec.describe Api::PaymentsController, type: :controller do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create_with_attachments(user: user) }

  describe "GET /payments/current" do
    login_user

    it "returns paginated current payments" do
      get :current

      expect(response).to have_http_status(:ok)
      expect(parsed_response['payments'].map { |o| o['id'] }).to match_array(FinanceObligation.current.ids)
      expect(parsed_response['total_pages']).to eq(1)
    end

    it "returns paginated current payments" do
      get :fixed

      expect(response).to have_http_status(:ok)
      expect(parsed_response['payments'].map { |o| o['id'] }).to match_array(FinanceObligation.fixed.ids)
      expect(parsed_response['total_pages']).to eq(1)
    end
  end
end
