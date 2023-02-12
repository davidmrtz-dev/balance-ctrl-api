require 'rails_helper'

RSpec.describe Payment, type: :model do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create(user: user) }
  let!(:outcome) { OutcomeFactory.create(balance: balance) }
  let!(:income) { IncomeFactory.create(balance: balance) }

  describe 'associations' do
    it { is_expected.to belong_to(:paymentable) }
  end

  describe 'validations' do
    describe 'one_payment_for_current_paymentable' do
      it 'should allow to have only one payment to current outcomes' do
        payment_01 = Payment.new(paymentable: outcome)
        expect(payment_01.valid?).to be_truthy
        payment_01.save!
        payment_02 = Payment.new(paymentable: outcome)
        expect(payment_02.valid?).to be_falsey
      end
    end
  end

  describe '#update_current_balance' do
    describe 'when paymentable is Outcome' do
      describe "when paymentable_type is 'fixed'" do
        it 'should substract the amount from balance current_amount' do
          payment = Payment.create!(paymentable: outcome, amount: 5_000)

          expect(balance.current_amount).to eq 5_000
        end
      end
    end

    describe 'when paymentable is Income' do
      describe "when paymentable_type is 'fixed'" do
        it 'should add the amount to balance current_amount' do
          payment = Payment.create!(paymentable: income, amount: 5_000)

          expect(balance.reload.current_amount).to eq 15_000
        end
      end
    end
  end
end
