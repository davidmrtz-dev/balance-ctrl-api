require 'rails_helper'

RSpec.describe Balance, type: :model do
  let(:user) { UserFactory.create }
  let(:balance) { BalanceFactory.create(user: user) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:transactions).dependent(:destroy) }
    it { is_expected.to have_many(:outcomes).dependent(:destroy) }
    it { is_expected.to have_many(:incomes).dependent(:destroy) }
    it { is_expected.to have_many(:balance_payments).dependent(:destroy) }
    it { is_expected.to have_many(:payments).through(:balance_payments) }
  end

  describe '#amount_incomes' do
    let(:balance_02) { BalanceFactory.create(user: user) }
    let(:income) do
      IncomeFactory.create(balance: balance, transaction_type: 'fixed', amount: 10_000, frequency: :monthly)
    end

    before do
      Timecop.freeze(1.month.ago) do
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

  describe '#amount_paid' do
    let!(:outcome) { OutcomeFactory.create(balance: balance, amount: 5_000) }

    it 'should return the sum of applied payments' do
      expect(balance.amount_paid).to eq(5_000)
    end
  end

  describe '#amount_to_be_paid' do
    let(:outcome) { OutcomeFactory.create(balance: balance, amount: 5_000) }

    before { outcome.payments.first.pending!}

    it 'should return the sum of pending payments' do
      expect(balance.amount_to_be_paid).to eq(5_000)
    end
  end

  describe '#amount_for_payments' do
    let(:outcome) { OutcomeFactory.create(balance: balance, amount: 5_000) }
    let!(:other_outcome) { OutcomeFactory.create(balance: balance, amount: 5_000) }

    before { outcome.payments.first.pending!}

    it 'should return the sum of pending payments' do
      expect(balance.amount_for_payments).to eq(10_000)
    end
  end
end
