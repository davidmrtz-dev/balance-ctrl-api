require 'rails_helper'

RSpec.describe Balance, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:transactions).dependent(:destroy) }
    it { is_expected.to have_many(:outcomes).dependent(:destroy) }
    it { is_expected.to have_many(:incomes).dependent(:destroy) }
    it { is_expected.to have_many(:balance_payments).dependent(:destroy) }
    it { is_expected.to have_many(:payments).through(:balance_payments) }
  end

  describe '#amount_incomes' do
    let(:user) { UserFactory.create }
    let(:balance) { BalanceFactory.create(user: user) }
    let(:balance_02) { BalanceFactory.create(user: user) }
    let(:income) do
      IncomeFactory.create(balance: balance, transaction_type: 'fixed', amount: 10_000, frequency: :monthly)
    end
    let(:billing) { BillingFactory.create(user: user, billing_type: :debit) }

    before do
      Timecop.freeze(1.month.ago) do
        BillingTransaction.create!(billing: billing, related_transaction: income)
        payment = PaymentFactory.create(paymentable: income, amount: 10_000)
        BalancePayment.create!(balance: balance, payment: payment)
        payment.applied!
      end

      payment_02 = PaymentFactory.create(paymentable: income, amount: 10_000)
      BalancePayment.create!(balance: balance_02, payment: payment_02)
      payment_02.applied!
    end

    it 'should return the sum of incomes' do
      expect(balance.amount_incomes).to eq(10_000)
      expect(balance_02.amount_incomes).to eq(10_000)
    end
  end
end
