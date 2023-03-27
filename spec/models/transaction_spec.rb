require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }
  let!(:type) { %w[Outcome Income].sample }

  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { is_expected.to have_many(:payments).dependent(:destroy) }
    it { should define_enum_for(:transaction_type).with_values(%i[current fixed]) }
    it { should have_db_column(:transaction_date).of_type(:date) }
    it { should define_enum_for(:frequency).with_values(%i[weekly biweekly monthly]) }
  end

  describe 'validations' do
    describe '#transaction_date_not_after_today' do
      it 'should not allow transaction_date of tomorrow' do
        transaction = Transaction.new(
          balance: balance,
          transaction_date: 1.day.from_now,
          amount: 10_000,
          type: type
        )

        expect(transaction.valid?).to be_falsey
        expect(transaction.errors.full_messages).to include('Transaction date can not be after today')
      end

      it 'should allow transaction_date of today' do
        transaction = Transaction.new(
          balance: balance,
          transaction_date: Time.zone.today,
          amount: 10_000,
          type: type
        )

        expect(transaction.valid?).to be_truthy
      end
    end

    describe '#transaction_date_current_month' do
      it 'should not allow transaction_date if it is not in current month' do
        transaction = Transaction.new(
          balance: balance,
          transaction_date: Time.zone.now.prev_month,
          amount: 10_000,
          type: type
        )

        expect(transaction.valid?).to be_falsey
        expect(transaction.errors.full_messages).to include('Transaction date should be in current month')
      end

      it 'should allow transaction_date if it is in current month' do
        transaction = Transaction.new(
          balance: balance,
          transaction_date: Time.zone.today,
          amount: 10_000,
          type: type
        )

        expect(transaction.valid?).to be_truthy
      end
    end
  end

  context '#after_create' do
    let!(:transaction) do
      Transaction.create!(
        balance: balance,
        amount: 10_000,
        transaction_date: Time.zone.now,
        type: type
      )
    end

    describe '#generate_payment' do
      it 'should create one payment' do
        expect do
          Transaction.create(
            balance: balance,
            amount: 5_000,
            transaction_date: Time.zone.now,
            type: type
          )
        end.to change { Payment.count }.by 1
      end

      it 'should set payment status as :applied' do
        expect(transaction.payments.first.status).to eq 'applied'
      end
    end
  end
end
