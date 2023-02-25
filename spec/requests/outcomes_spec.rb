require 'rails_helper'

RSpec.describe Api::OutcomesController, type: :controller do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create_with_attachments(user: user) }

  describe 'GET /api/outcomes' do
    login_user

    it 'return paginated outcomes' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:outcomes].map { |o| o[:id] }).to match_array(Outcome.ids)
    end
  end

  describe "GET /api/outcomes/current" do
    login_user

    it "returns paginated current outcomes" do
      get :current

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:outcomes].map { |o| o[:id] }).to match_array(Outcome.current.ids)
      expect(parsed_response[:total_pages]).to eq 1
    end
  end

  describe 'GET /api/outcomes/fixed' do
    login_user

    it "returns paginated fixed outcomes" do
      get :fixed

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:outcomes].map { |o| o[:id] }).to match_array(Outcome.fixed.ids)
      expect(parsed_response[:total_pages]).to eq 1
    end
  end

  describe 'GET /api/outcomes/search' do
    login_user

    it 'return paginated outcomes based on keyword for description' do
      get :search, params: {
        keyword: 'Baby'
      }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /api/outcomes' do
    subject(:action) {
      post :create, params: {
        outcome: {
          transaction_type: 'current',
          amount: 4500,
          description: 'Clothes',
          purchase_date: Time.zone.now
        }
      }
    }

    login_user

    it 'creates an outcome' do
      expect { action }.to change { Outcome.count }.by 1

      action

      expect(response).to have_http_status(:no_content)
    end

    it 'handles validation error' do
      post :create, params: {
        outcome: {
          purchase_date: nil
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PUT /api/outcomes/:id' do
    let!(:outcome) do
      OutcomeFactory.create(
        balance: balance,
        purchase_date: Time.zone.today,
        description: 'Grocery',
        amount: 4000
      )
    end

    subject(:action) do
      put :update, params: {
        id: outcome.id,
        outcome: {
          description: 'Clothes',
          amount: 6000
        }
      }
    end

    login_user

    it 'calls to update the outcome' do
      expect(outcome.description).to eq 'Grocery'
      expect(outcome.amount).to eq 4000

      action

      outcome.reload

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:outcome][:id]).to eq outcome.id
      expect(outcome.description).to eq 'Clothes'
      expect(outcome.amount).to eq 6000
    end

    it 'handles validation error' do
      put :update,
        params: {
          id: outcome.id,
          outcome: {
            purchase_date: nil
          }
        }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_response[:errors].first).to eq "Purchase date can't be blank"
    end
  end

  describe 'DELETE /api/outcomes/:id' do
    let!(:outcome) { OutcomeFactory.create(balance: balance, purchase_date: Time.zone.today) }

    subject(:action) { delete :destroy, params: { id: outcome.id } }

    login_user

    it 'calls to delete the outcome' do
      expect { action }.to change { Outcome.count }.by -1

      action

      expect(response).to have_http_status(:no_content)
    end

    it 'handles not found' do
      expect { delete :destroy, params: { id: 0 } }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
