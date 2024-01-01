require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }
  let(:outcome) { OutcomeFactory.create(balance: balance, amount: 100) }

  describe 'associations' do
    it { is_expected.to belong_to(:paymentable) }
    it { is_expected.to belong_to(:refund).optional }
    it { should define_enum_for(:status).with_values(%i[hold pending applied expired cancelled refund]) }
    it { is_expected.to have_many(:balance_payments).dependent(:destroy) }
    it { is_expected.to have_many(:balances).through(:balance_payments) }
  end

  describe 'validations' do
    let(:outcome) { OutcomeFactory.create(balance: balance) }

    describe '#only_one_payment_for_current' do
      context "when paymentable is Outcome and is 'current'" do
        context 'when there is no refund' do
          it 'should allow only one payment' do
            refund = Payment.new(paymentable: outcome, status: :refund)

            expect(refund.valid?).to be_truthy
          end
        end

        it 'should not allow more than one payment' do
          payment_02 = Payment.new(paymentable: outcome, status: :applied)

          expect(payment_02.valid?).to be_falsey
          expect(payment_02.errors.full_messages)
            .to include('Paymentable of type current can only have one payment')
        end
      end
    end

    describe '#only_one_refund_for_current' do
      context "when paymentable is Outcome and is 'current'" do
        context 'when theres is an existing refund payment' do
          before do
            PaymentFactory.create(paymentable: outcome, status: :refund)
          end

          it 'should not allow more than one refunds' do
            other_refund = Payment.new(paymentable: outcome, status: :refund)

            expect(other_refund.valid?).to be_falsey
            expect(other_refund.errors.full_messages)
              .to include('Paymentable of type current can only have one refund')
          end
        end
      end
    end
  end

  describe '#before_update' do
    describe '#substract_from_balance_amount' do
      context 'when payment status is :applied' do
        subject { outcome.payments.hold.first.applied! }

        it 'substracts amount from balance current_amount' do
          expect { subject }.to change { balance.current_amount }.by(-100)
        end
      end
    end

    describe '#update_balance_amount' do
      context 'when payment status is :applied && status was :applied' do
        subject { outcome.update!(amount: 300) }

        before { outcome.payments.hold.first.applied! }

        it 'updates balance current_amount' do
          expect { subject }.to change { balance.current_amount }.by(-200)
        end
      end
    end
  end

  describe '#after_create' do
    describe '#add_to_balance_amount' do
      context 'when payment status is :refund' do
        subject { PaymentFactory.create(paymentable: outcome, status: :refund, amount: 200) }

        it 'adds amount to balance current_amount' do
          expect { subject }.to change { balance.current_amount }.by(200)
        end
      end
    end
  end
end
