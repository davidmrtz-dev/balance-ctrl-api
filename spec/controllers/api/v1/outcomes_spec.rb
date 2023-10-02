require 'rails_helper'

RSpec.describe Api::V1::OutcomesController, type: :controller do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create_with_attachments(user: user) }

  describe 'GET /api/v1/outcomes' do
    login_user

    it 'return paginated outcomes' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:outcomes].pluck(:id)).to match_array(Outcome.ids)
    end
  end

  describe 'GET /api/v1/outcomes/current' do
    login_user

    it 'returns paginated current outcomes' do
      get :current

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:outcomes].pluck(:id)).to match_array(Outcome.current.ids)
      expect(parsed_response[:total_pages]).to eq 1
    end
  end

  describe 'GET /api/v1/outcomes/fixed' do
    login_user

    it 'returns paginated fixed outcomes' do
      get :fixed

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:outcomes].pluck(:id)).to match_array(Outcome.fixed.ids)
      expect(parsed_response[:total_pages]).to eq 1
    end
  end

  describe 'GET /api/v1/outcomes/search' do
    login_user

    it 'return paginated outcomes based on keyword for description' do
      get :search, params: {
        keyword: 'Baby'
      }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /api/v1/outcomes' do
    let(:valid_params) do
      {
        outcome: {
          amount: 4500,
          description: 'Clothes',
          transaction_date: Time.zone.now
        }
      }
    end

    subject(:create_outcome) { post :create, params: valid_params }

    login_user

    context 'when category is present' do
      let(:category) { CategoryFactory.create }

      before { valid_params.merge!(outcome: valid_params[:outcome].merge(category_id: category.id)) }

      it 'creates an outcome with a category and categorization' do
        expect { create_outcome }
          .to change { Outcome.count }.by(1)
          .and change { Categorization.count }.by(1)

        outcome = Outcome.last

        expect(response).to have_http_status(:created)
        expect(parsed_response[:outcome][:id]).to eq outcome.id
        expect(outcome.description).to eq 'Clothes'
        expect(outcome.amount).to eq 4500
        expect(outcome.categories.first).to eq(category)
      end
    end

    context 'when billing is present' do
      let(:billing) { BillingFactory.create(user: user) }

      before { valid_params.merge!(outcome: valid_params[:outcome].merge(billing_id: billing.id)) }

      it 'creates an outcome with a billing and billing transaction' do
        expect { create_outcome }
          .to change { Outcome.count }.by(1)
          .and change { BillingTransaction.count }.by(1)

        outcome = Outcome.last

        expect(response).to have_http_status(:created)
        expect(parsed_response[:outcome][:id]).to eq outcome.id
        expect(outcome.description).to eq 'Clothes'
        expect(outcome.amount).to eq 4500
        expect(outcome.billings.first).to eq(billing)
      end
    end

    it 'creates an outcome' do
      expect { create_outcome }.to change { Outcome.count }.by(1)

      outcome = Outcome.last

      expect(response).to have_http_status(:created)
      expect(parsed_response[:outcome][:id]).to eq outcome.id
      expect(outcome.description).to eq 'Clothes'
      expect(outcome.amount).to eq 4500
    end

    it 'handles validation error' do
      post :create, params: {
        outcome: {
          transaction_date: nil
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PUT /api/v1/outcomes/:id' do
    let(:outcome) do
      OutcomeFactory.create(
        balance: balance,
        description: 'Apple Watch',
        amount: 4000
      )
    end
    let(:category) { CategoryFactory.create }
    let(:billing) { BillingFactory.create(user: user) }

    let(:valid_params) do
      {
        id: outcome.id,
        outcome: {
          description: 'Macbook Pro',
          amount: 6000
        }
      }
    end

    subject(:update_outcome) { put :update, params: valid_params }

    login_user

    before do
      outcome.categories << category
      outcome.billings << billing
    end

    context 'when category is present' do
      let(:other_category) { CategoryFactory.create }

      before do
        valid_params.merge!(
          outcome: valid_params[:outcome]
            .merge(
              categorizations_attributes: [{ category_id: other_category.id }]
            )
        )
      end

      it 'updates the outcome with the provided category' do
        update_outcome

        outcome = Outcome.last

        expect(response).to have_http_status(:ok)
        expect(parsed_response[:outcome][:id]).to eq outcome.id
        expect(outcome.description).to eq 'Macbook Pro'
        expect(outcome.amount).to eq 6000
        expect(outcome.categories.first).to eq(other_category)
      end
    end

    context 'when billing is present' do
      let(:other_billing) { BillingFactory.create(user: user) }

      before do
        valid_params.merge!(
          outcome: valid_params[:outcome]
          .merge(
            billing_transactions_attributes: [{ billing_id: other_billing.id }]
          )
        )
      end

      it 'updates the outcome with the provided category' do
        update_outcome

        outcome = Outcome.last

        expect(response).to have_http_status(:ok)
        expect(parsed_response[:outcome][:id]).to eq outcome.id
        expect(outcome.description).to eq 'Macbook Pro'
        expect(outcome.amount).to eq 6000
        expect(outcome.billings.first).to eq(other_billing)
      end
    end

    it 'calls to update the outcome' do
      expect(outcome.description).to eq 'Apple Watch'
      expect(outcome.amount).to eq 4000

      update_outcome

      outcome.reload

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:outcome][:id]).to eq outcome.id
      expect(outcome.description).to eq 'Macbook Pro'
      expect(outcome.amount).to eq 6000
    end

    it 'handles validation error' do
      put :update,
          params: {
            id: outcome.id,
            outcome: {
              transaction_date: nil
            }
          }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/v1/outcomes/:id' do
    let!(:outcome) { OutcomeFactory.create(balance: balance) }

    subject(:action) { delete :destroy, params: { id: outcome.id } }

    login_user

    it 'should allow the outcome deletion' do
      action

      outcome.reload

      expect(response).to have_http_status(:no_content)
      expect(outcome.discarded?).to be_truthy
    end

    it 'handles not found' do
      delete :destroy, params: { id: 0 }

      expect(response).to have_http_status(:not_found)
    end
  end
end
