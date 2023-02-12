require 'rails_helper'

RSpec.describe Income, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { should define_enum_for(:frequency).with_values(%i[weekly biweekly monthly]) }
  end

  describe 'validations' do
    it { should allow_value(:monthly).for(:frequency).on(:create) }
    it { should_not allow_value(Time.zone.today).for(:purchase_date).on(:create) }
    it { should_not allow_value(12).for(:quotas).on(:create) }
  end

  describe '#generate_payment' do
    let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
    let!(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }

    it "should create one payment for transaction_type 'current'" do
      expect { Income.create(balance: balance, transaction_type: :current, amount: 5_000, frequency: :monthly) }
        .to change { Payment.count }.by(1)
    end
  end
end
