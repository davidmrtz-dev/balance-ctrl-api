require 'rails_helper'

RSpec.describe Api::OutcomesController, type: :controller do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create_with_attachments(user: user) }

  describe "GET /api/outcomes/current" do
    login_user

    it "returns paginated current outcomes" do
      get :current

      expect(response).to have_http_status(:ok)
      expect(parsed_response['outcomes'].map { |o| o['id'] }).to match_array(Outcome.current.ids)
      expect(parsed_response['total_pages']).to eq(1)
    end

    it "returns paginated current outcomes" do
      get :fixed

      expect(response).to have_http_status(:ok)
      expect(parsed_response['outcomes'].map { |o| o['id'] }).to match_array(Outcome.fixed.ids)
      expect(parsed_response['total_pages']).to eq(1)
    end
  end

  describe 'POST /api/outcomes' do
    subject(:action) {
      post :create, params: {
        outcome: {
          balance_id: balance.id,
          amount: 4500,
          description: 'Clothes',
          purchase_date: Time.zone.now
        }
      }
    }

    login_user

    it 'creates an outcome and returns it' do
      action

      outcome = Outcome.last

      expect(response).to have_http_status(:created)
      expect(parsed_response[:outcome][:id]).to eq(outcome.id)
    end

    it 'handles validation error' do
      post :create,
           params: {
             outcome: {
               balance_id: nil,
               purchase_date: nil
             }
           }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_response[:id]).to be_nil
    end
  end

  describe 'DESTROY /api/outcomes/:id' do
    let!(:outcome) { OutcomeFactory.create(balance: balance, purchase_date: Time.zone.today) }

    subject(:action) { delete :destroy, params: { id: outcome.id } }

    login_user

    it 'calls to delete the outcome' do
      expect { action }.to change { Outcome.count }.by -1

      action
      expect(response).to have_http_status(:no_content)
    end
  end
end