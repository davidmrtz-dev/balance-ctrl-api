require 'rails_helper'

RSpec.describe Payment, type: :model do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }

  describe 'associations' do
    it { is_expected.to belong_to(:paymentable) }
  end

  describe 'validations' do
    let!(:income) { IncomeFactory.create(balance: balance, frequency: :monthly) }
    let!(:outcome) { OutcomeFactory.create(balance: balance, transaction_type: :current, purchase_date: Time.zone.today) }

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
    let!(:income) { IncomeFactory.create(balance: balance, frequency: :monthly) }
    let!(:outcome) { OutcomeFactory.create(balance: balance, transaction_type: :current, purchase_date: Time.zone.today) }

    shared_examples 'update_status_when_apply_payment' do
      it 'should update status to :applied' do
        expect(payment.status).to eq 'applied'
      end
    end

    describe "when paymentable is Outcome and is 'fixed'" do
      let!(:payment) { PaymentFactory.create(paymentable: outcome, amount: 5_000) }

      it 'should substract the amount from balance current_amount' do
        expect(balance.reload.current_amount).to eq 5_000
      end

      include_examples 'update_status_when_apply_payment'
    end

    describe "when paymentable is Income is 'fixed'" do
      let!(:payment) { PaymentFactory.create(paymentable: income, amount: 5_000) }

      it 'should add the amount to balance current_amount' do
        expect(balance.reload.current_amount).to eq 15_000
      end

      include_examples 'update_status_when_apply_payment'
    end
  end
end
