require 'rails_helper'

RSpec.describe Income, type: :model do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }

  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { should define_enum_for(:frequency).with_values(%i[weekly biweekly monthly]) }
  end

  describe 'validations' do
    it { should allow_value(:monthly).for(:frequency).on(:create) }
    it { should_not allow_value(Time.zone.today).for(:purchase_date).on(:create) }
    it { should_not allow_value(12).for(:quotas).on(:create) }
  end

  describe '#update_balance_amount' do
    it 'should sum the amount to balance current_amount' do
      Income.create(balance: balance, amount: 5_000, frequency: :monthly)

      expect(balance.reload.current_amount).to eq 15_000
    end
  end

  describe '#generate_payment' do
    it "should create one payment for transaction_type 'current'" do
      expect { Income.create(balance: balance, amount: 5_000, frequency: :monthly) }
        .to change { Payment.count }.by(1)

      expect(Payment.last.status).to eq 'applied'
    end
  end
end
