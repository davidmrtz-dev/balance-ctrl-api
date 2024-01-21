require 'rails_helper'

RSpec.describe Outcome, type: :model do
  let(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }

  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { should have_db_column(:transaction_date).of_type(:date) }
  end

  describe 'validations' do
    it { should validate_absence_of(:frequency) }
    it { should validate_presence_of(:transaction_date) }
    it { is_expected.to validate_numericality_of(:amount) }
    it { should_not allow_value(Time.zone.tomorrow).for(:transaction_date) }
    [
      1,
      50,
      1000
    ].each do |value|
      it { should allow_value(value).for(:amount) }
    end

    context 'when outcome is :current' do
      it "should validate absence of 'quotas'" do
        outcome = Outcome.new(balance: balance, transaction_date: Time.zone.now, quotas: 12, amount: 1)
        expect(outcome.valid?).to be_falsey
        expect(outcome.errors.full_messages).to include('Quotas must be blank')
      end
    end

    context 'when outcome is :fixed' do
      it "should validate presence of 'quotas'" do
        outcome = Outcome.new(balance: balance, transaction_type: :fixed, transaction_date: Time.zone.now, amount: 1)
        expect(outcome.valid?).to be_falsey
        expect(outcome.errors.full_messages).to include("Quotas can't be blank")
      end
    end
  end

  context '#before_discard' do
    describe '#generate_refunds' do
      context 'when outcome is :current' do
        subject(:outcome) { OutcomeFactory.create(balance: balance) }

        before do
          subject.payments.first.applied!
          subject.discard!
        end

        it 'should create one payment with refund status' do
          expect(subject.payments.refund.count).to eq 1
        end

        it 'should set payment amount as outcome.amount' do
          expect(subject.payments.refund.first.amount).to eq subject.amount
        end
      end

      context 'when outcome is :fixed' do
        subject(:outcome) do
          OutcomeFactory.create(
            balance: balance,
            transaction_type: :fixed,
            amount: 12_000,
            quotas: 12
          )
        end

        before do
          subject.payments.first(6).each(&:applied!)
          subject.discard!
        end

        it 'should create refunds for applied payments' do
          expect(subject.payments.refund.count).to eq 6
        end

        it 'should set refund amount equal to applied payment amount' do
          refund_payments = subject.payments.refund
          applied_payments = subject.payments.applied

          refund_payments.each_with_index do |refund_payment, index|
            expect(refund_payment.amount).to eq applied_payments[index].amount
          end
        end
      end
    end
  end

  context '#after_create' do
    describe '#generate_payments' do
      context 'when outcome is :current' do
        subject(:outcome) { OutcomeFactory.create(balance: balance) }

        it 'should create one payment with applied status' do
          expect(subject.payments.applied.count).to eq 1
        end

        it 'should set payment amount as outcome.amount' do
          expect(subject.payments.applied.first.amount).to eq subject.amount
        end
      end

      context 'when outcome is :fixed' do
        subject(:outcome) do
          OutcomeFactory.create(
            balance: balance,
            transaction_type: :fixed,
            amount: 12_000,
            quotas: 12
          )
        end

        it "'should create n 'quotas' payments" do
          expect(subject.payments.hold.count).to eq subject.quotas
        end

        it "should create payments with state as 'hold'" do
          expect(subject.payments.pluck(:status).uniq.first).to eq 'hold'
        end

        it 'should create payment with amount as outcome.amount / outcome.quotas' do
          expect(subject.payments.last.amount).to eq outcome.amount / outcome.quotas
        end
      end
    end
  end
end
