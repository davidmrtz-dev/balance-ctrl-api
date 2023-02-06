require 'rails_helper'

RSpec.describe Api::PaymentsController, type: :controller do
  describe "GET /payments" do
    login_user

    it "returns head ok" do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end
end
