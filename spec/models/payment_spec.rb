require 'rails_helper'

RSpec.describe Payment, type: :model do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }

  describe 'associations' do
    it { is_expected.to belong_to(:paymentable) }
  end

  describe 'validations' do
    let!(:income) { IncomeFactory.create(balance: balance, income_type: :current, income_frequency: :monthly) }
    let!(:outcome) { OutcomeFactory.create(balance: balance, outcome_type: :current, purchase_date: Time.zone.today) }

    describe 'one_payment_for_current_outcome' do
      describe "when paymentable is Income and is 'fixed'" do
        it 'should not be valid if payments > 0' do
          payment_01 = PaymentFactory.create(paymentable: income)
          payment_02 = Payment.new(paymentable: income)

          expect(payment_02.valid?).to be_falsey
          expect(payment_02.errors.full_messages.first).
            to eq('Income of type current can only have one payment')
        end
      end

      describe "when paymentable is Outcome and is 'fixed'" do
        it 'should not be valid if payments > 0' do
          payment_01 = PaymentFactory.create(paymentable: outcome)
          payment_02 = Payment.new(paymentable: outcome)

          expect(payment_02.valid?).to be_falsey
          expect(payment_02.errors.full_messages.first).
          to eq('Outcome of type current can only have one payment')
        end
      end
    end
  end

  describe '#update_current_balance' do
    let!(:income) { IncomeFactory.create(balance: balance, income_type: :current, income_frequency: :monthly) }
    let!(:outcome) { OutcomeFactory.create(balance: balance, outcome_type: :current, purchase_date: Time.zone.today) }

    describe "when paymentable is Outcome and is 'fixed'" do
      it 'should substract the amount from balance current_amount' do
        payment = PaymentFactory.create(paymentable: outcome, amount: 5_000)

        expect(balance.reload.current_amount).to eq 5_000
      end
    end

    describe "when paymentable is Income is 'fixed'" do
      it 'should add the amount to balance current_amount' do
        payment = PaymentFactory.create(paymentable: income, amount: 5_000)

        expect(balance.reload.current_amount).to eq 15_000
      end
    end
  end
end
