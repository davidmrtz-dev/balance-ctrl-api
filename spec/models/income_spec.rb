require 'rails_helper'

RSpec.describe Income, type: :model do
  let(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }

  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { should define_enum_for(:frequency).with_values(%i[weekly biweekly monthly]) }
  end

  describe 'validations' do
    it { should validate_absence_of(:quotas) }
    it { should validate_presence_of(:transaction_date) }
    it { is_expected.to validate_numericality_of(:amount) }
    it { should_not allow_value(0).for(:amount) }
    [
      1,
      50,
      1000
    ].each do |value|
      it { should allow_value(value).for(:amount) }
    end

    context 'when income is :current' do
      it 'should not allow value of frequency' do
        income = Income.new(balance: balance, amount: 1_000, frequency: :monthly)

        expect(income.valid?).to be_falsey
      end
    end

    context 'when income is :fixed' do
      it 'should require value of frequency' do
        income = Income.new(
          balance: balance,
          amount: 1_000,
          frequency: :monthly,
          transaction_type: :fixed,
          transaction_date: Time.zone.now
        )

        expect(income.valid?).to be_truthy
      end
    end
  end

  context '#after_create' do
    describe '#generate_payment' do
      context 'when income is :current' do
        subject(:income) { IncomeFactory.create(balance: balance) }

        it 'should create one payment with hold status' do
          expect(subject.payments.hold.count).to eq 1
        end

        it 'should set payment amount as outcome.amount' do
          expect(subject.payments.hold.first.amount).to eq subject.amount
        end
      end
    end
  end

  context '#before_discard' do
    describe '#generate_refund' do
      context 'when income is :current' do
        subject(:income) { IncomeFactory.create(balance: balance) }

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
    end
  end
end
