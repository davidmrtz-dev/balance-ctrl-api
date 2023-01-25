require 'rails_helper'

RSpec.describe "Balances", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/balances/index"
      expect(response).to have_http_status(:success)
    end
  end

end
