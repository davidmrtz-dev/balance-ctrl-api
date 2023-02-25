require 'rails_helper'

RSpec.describe Api::IncomesController, type: :controller do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create_with_attachments(user: user) }

  describe 'GET /api/incomes' do
    login_user

    it 'returns paginated incomes' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:incomes].map { |i| i[:id] }).to match_array(Income.ids)
    end
  end

  describe 'POST /api/incomes' do
    subject(:action) {
      post :create, params: {
        income: {
          amount: 10_000,
          description: 'Salary',
          frequency: :monthly
        }
      }
    }

    login_user

    it 'creates an income' do
      expect { action }.to change { Income.count }.by 1

      action

      income = Income.last

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
            frequency: nil
          }
        }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/incomes/:id' do
    let!(:income) { IncomeFactory.create(balance: balance) }

    subject(:action) { delete :destroy, params: { id: income.id }}

    login_user

    it 'calls to delete the income' do
      expect { action }.to change { Income.count }.by -1

      action

      expect(response).to have_http_status(:no_content)
    end

    it 'handles not found' do
      expect { delete :destroy, params: { id: 0 } }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end