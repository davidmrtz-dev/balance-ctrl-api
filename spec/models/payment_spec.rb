require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }
  let(:outcome) { OutcomeFactory.create(balance: balance, amount: 100) }

  describe 'associations' do
    it { is_expected.to belong_to(:paymentable) }
    it { should define_enum_for(:status).with_values(%i[hold pending applied expired cancelled refund]) }
  end

  describe 'validations' do
    let(:outcome) { OutcomeFactory.create(balance: balance) }

    describe '#only_one_not_refund_for_current' do
      context "when paymentable is Outcome and is 'current'" do
        context 'when there is no refund' do
          it 'should allow one refund payment' do
            refund = Payment.new(paymentable: outcome, status: :refund)

            expect(refund.valid?).to be_truthy
          end
        end

        it 'should allow one not refund payment' do
          payment_02 = Payment.new(paymentable: outcome, status: :applied)

          expect(payment_02.valid?).to be_falsey
          expect(payment_02.errors.full_messages)
            .to include('Paymentable of type current can only have one applied payment')
        end
      end
    end

    describe '#only_one_refund_for_current' do
      context "when paymentable is Outcome and is 'current'" do
        context 'when theres is an existing refund payment' do
          before do
            PaymentFactory.create(paymentable: outcome, status: :refund)
          end

          it 'should not allow multiple refunds' do
            other_refund = Payment.new(paymentable: outcome, status: :refund)

            expect(other_refund.valid?).to be_falsey
            expect(other_refund.errors.full_messages)
              .to include('Paymentable of type current can only have one refund payment')
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

  describe '.reset_to_hold' do
    context 'when payment status is :applied' do
      subject { outcome.payments.applied.first.reset_to_hold }

      before { outcome.payments.hold.first.applied! }

      it 'updates payment status to :hold' do
        expect { subject }.to change { outcome.payments.hold.count }.by(1)
      end

      it 'adds amount to balance current_amount' do
        expect { subject }.to change { balance.current_amount }.by(100)
      end
    end
  end
end
