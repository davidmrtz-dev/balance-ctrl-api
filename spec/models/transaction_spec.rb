require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }
  let!(:type) { ['Outcome', 'Income'].sample }

  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { is_expected.to have_many(:payments).dependent(:destroy) }
    it { should define_enum_for(:transaction_type).with_values(%i[current fixed]) }
    it { should have_db_column(:transaction_date).of_type(:date) }
    it { should define_enum_for(:frequency).with_values(%i[weekly biweekly monthly]) }
  end

  context '#after_create' do
    let!(:transaction) do
      Transaction.create!(
        balance: balance,
        amount: 10_000,
        transaction_date: Time.zone.now,
        type: type
      )
    end

    describe '#generate_payment' do
      it 'should create one payment' do
        expect do
          Transaction.create(
            balance: balance,
            amount: 5_000,
            transaction_date: Time.zone.now,
            type: type
          )
        end.to change { Payment.count }.by 1
      end

      it 'should set payment status as :applied' do
        expect(transaction.payments.first.status).to eq 'applied'
      end
    end
  end
end
