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
    it { should validate_presence_of(:transaction_date) }
    it { should validate_numericality_of(:amount).is_greater_than(0.0) }
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

    describe '#only_one_billing' do
      let(:billing) { BillingFactory.create(user: user) }
      let(:other_billing) { BillingFactory.create(user: user) }

      subject(:transaction) do
        Transaction.create!(
          balance: balance,
          amount: 10_000,
          transaction_date: Time.zone.today,
          type: type
        )
      end

      context 'when there is only one billing transaction' do
        let!(:billing_transaction) { BillingTransaction.create!(billing: billing, related_transaction: transaction) }

        it 'does not add error' do
          expect(transaction).to be_valid
        end
      end

      context 'when there are multiple billing transactions' do
        let!(:billing_transaction_1) { BillingTransaction.create!(billing: billing, related_transaction: transaction) }
        let!(:billing_transaction_2) { BillingTransaction.create!(billing: other_billing, related_transaction: transaction) }

        it 'adds error' do
          expect(transaction).not_to be_valid
          expect(transaction.errors[:billing_transactions]).to include('Only one billing is allowed for transactions')
        end
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

  context '#before_save' do
    describe '#remove_previous_categorizations' do
      let(:category) { CategoryFactory.create(name: 'Grocery') }
      let(:other_category) { CategoryFactory.create(name: 'Clothes') }

      subject(:transaction) do
        Transaction.create!(
          balance: balance,
          amount: 10_000,
          transaction_date: Time.zone.today,
          type: type
        )
      end

      before { transaction.categories << category }

      context 'when there are persisted categorizations and new ones' do
        it 'should remove persisted categorizations and keep new one' do
          transaction.update!(categorizations_attributes: [{ category_id: other_category.id }])

          expect(transaction.categorizations.count).to eq 1
          expect(transaction.categories.first).to eq other_category
        end
      end
    end

    describe '#remove_previouse_billing_transactions' do
      let(:billing) { BillingFactory.create(user: user) }
      let(:other_billing) { BillingFactory.create(user: user) }

      subject(:transaction) do
        Transaction.create!(
          balance: balance,
          amount: 10_000,
          transaction_date: Time.zone.today,
          type: type
        )
      end

      before { transaction.billings << billing }

      context 'when there are persisted billing_transactions and new ones' do
        it 'should remove persisted billing_transactions and keep new one' do
          transaction.update!(billing_transactions_attributes: [{ billing_id: other_billing.id }])

          expect(transaction.billing_transactions.count).to eq 1
          expect(transaction.billings.first).to eq other_billing
        end
      end
    end
  end
end
