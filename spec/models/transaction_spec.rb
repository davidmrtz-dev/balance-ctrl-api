require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }
  let(:type) { %w[Outcome Income].sample }

  describe 'associations' do
    it { is_expected.to belong_to(:balance) }
    it { is_expected.to have_many(:payments).dependent(:destroy) }
    it { should define_enum_for(:transaction_type).with_values(%i[current fixed]) }
    it { should have_db_column(:transaction_date).of_type(:date) }
    it { should define_enum_for(:frequency).with_values(%i[weekly biweekly monthly]) }
    it { is_expected.to have_many(:billing_transactions) }
    it { is_expected.to have_many(:billings).through(:billing_transactions) }
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
          transaction_date: Time.zone.today.prev_month,
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
    subject(:transaction) do
      Transaction.create!(
        balance: balance,
        amount: 10_000,
        transaction_date: Time.zone.today,
        type: type
      )
    end

    describe '#generate_payment' do
      it 'should create one payment' do
        expect { transaction }.to change { Payment.count }.by 1
      end

      it 'should set payment status as :applied' do
        expect(transaction.payments.first.status).to eq 'applied'
      end
    end
  end

  context '#before_destroy' do
    subject(:transaction) do
      Transaction.create!(
        balance: balance,
        amount: 10_000,
        transaction_date: Time.zone.today,
        type: type
      )
    end

    describe '#check_same_month' do
      it 'should not allow destruction if created in a different month' do
        transaction.update(created_at: Time.zone.today.prev_month)

        expect { transaction.destroy }.not_to change(Transaction, :count)
        expect(transaction.errors[:base]).to include('Can only delete transactions created in the current month')
      end

      it 'should allow destruction if created in the same month' do
        transaction.update(created_at: Time.zone.today)

        expect { transaction.destroy }.to change { Transaction.count }.by(-1)
      end
    end
  end

  context '#before_discard' do
    subject(:transaction) do
      Transaction.create!(
        balance: balance,
        amount: 10_000,
        transaction_date: Time.zone.today,
        type: 'Income',
        transaction_type: :fixed,
        frequency: :monthly
      )
    end

    describe '#check_same_month' do
      it 'should not allow discarding if created in a different month' do
        transaction.update(created_at: Time.zone.today.prev_month)

        expect(transaction.discard).to be_falsey
      end

      it 'should allow discarding if created in the same month' do
        transaction.update(created_at: Time.zone.today)

        expect(transaction.discard).to be_truthy
      end
    end
  end
end
