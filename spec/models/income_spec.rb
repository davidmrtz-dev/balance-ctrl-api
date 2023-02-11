require 'rails_helper'

RSpec.describe Income, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { should define_enum_for(:income_frequency).with_values(%i[weekly biweekly monthly]) }
    it { should define_enum_for(:active_type).with_values(%i[fixed current]) }
  end

  describe '.update_current_balance' do
    let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
    let!(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }

    it 'should update balance current_amount attribute' do
      income = IncomeFactory.create(balance: balance, amount: 5_000)

      expect(balance.current_amount.to_f).to eq 15_000
    end
  end
end
