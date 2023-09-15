require 'rails_helper'

RSpec.describe Api::V1::IncomesController, type: :controller do
  let(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create_with_attachments(user: user) }

  describe 'GET /api/incomes' do
    login_user

    it 'returns paginated incomes' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:incomes].pluck(:id)).to match_array(Income.ids)
    end
  end

  describe 'POST /api/incomes' do
    subject(:action) do
      post :create, params: {
        income: {
          amount: 10_000,
          description: 'Salary',
          transaction_date: Time.zone.now
        }
      }
    end

    login_user

    it 'creates an income' do
      expect { action }.to change { Income.count }.by 1

      action

      income = Income.first

      expect(response).to have_http_status(:created)
      expect(parsed_response[:income][:id]).to eq income.id
    end

    it 'handles validation error' do
      post :create, params: {
        income: {
          frequency: nil
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PUT /api/incomes/:id' do
    let!(:income) do
      IncomeFactory.create(
        balance: balance,
        description: 'Salary',
        amount: 10_000
      )
    end

    subject(:action) do
      put :update, params: {
        id: income.id,
        income: {
          description: 'Bonus',
          amount: 20_000
        }
      }
    end

    login_user

    it 'calls to update the income' do
      expect(income.description).to eq 'Salary'
      expect(income.amount).to eq 10_000

      action

      income.reload

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:income][:id]).to eq income.id
      expect(income.description).to eq 'Bonus'
      expect(income.amount).to eq 20_000
    end

    it 'handles validation error' do
      put :update,
          params: {
            id: income.id,
            income: {
              frequency: 'monthly',
              transaction_type: 'fixed'
            }
          }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/incomes/:id' do
    subject(:action) { delete :destroy, params: { id: income.id } }

    login_user

    context 'when income is current' do
      let!(:income) { IncomeFactory.create(balance: balance) }

      it 'calls to delete the income' do
        expect { action }.to change { Income.count }.by(-1)
          .and change { Payment.count }.by(-1)

        action

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when income is fixed' do
      let!(:income) { IncomeFactory.create(balance: balance, transaction_type: :fixed, frequency: :monthly) }

      it 'does mark the income as discarded' do
        expect { action }.not_to change(Income.unscoped, :count)

        action

        income.reload

        expect(response).to have_http_status(:no_content)
        expect(income.discarded?).to be_truthy
      end
    end

    it 'handles not found' do
      delete :destroy, params: { id: 0 }

      expect(response).to have_http_status(:not_found)
    end
  end
end
