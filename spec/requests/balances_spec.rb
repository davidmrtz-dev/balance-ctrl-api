require 'rails_helper'

RSpec.describe "Balances", type: :request do
  describe "GET /balance" do
    it "returns no content" do
      get :balance
      expect(response).to have_http_status(:no_content)
    end
  end
end
