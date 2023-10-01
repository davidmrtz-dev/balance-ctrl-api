require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }

  describe 'associations' do
    it { is_expected.to belong_to(:paymentable) }
    it { should define_enum_for(:status).with_values(%i[hold pending applied expired cancelled]) }
  end

  describe 'validations' do
    let(:outcome) { OutcomeFactory.create(balance: balance) }

    describe 'one_payment_for_current_outcome' do
      describe "when paymentable is Outcome and is 'current'" do
        it 'should not be valid if payments > 0' do
          payment_02 = Payment.new(paymentable: outcome)

          expect(payment_02.valid?).to be_falsey
          expect(payment_02.errors.full_messages)
            .to include('Paymentable of type current can only have one payment')
        end
      end
    end
  end
end
