require 'rails_helper'

RSpec.describe Api::PaymentsController, type: :controller do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create_with_attachments(user: user) }

  describe "GET /payments" do
    login_user

    it "returns paginated fixed and current payments" do
      get :index

      expect(response).to have_http_status(:ok)
      expect(parsed_response['fixed'].map { |o| o['id'] }).to match_array(FinanceObligation.fixed.ids)
      expect(parsed_response['total_fixed']).to eq(4)
      expect(parsed_response['current'].map { |o| o['id'] }).to match_array(FinanceObligation.current.ids)
      expect(parsed_response['total_current']).to eq(2)
    end
  end
end
