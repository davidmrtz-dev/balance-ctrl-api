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
          transaction_date: Time.zone.tomorrow,
          amount: 10_000,
          type: type
        )

        expect(transaction.valid?).to be_falsey
        expect(transaction.errors.full_messages).to include('Transaction date cannot be after today')
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
      let(:outcome) { OutcomeFactory.create(balance: balance) }
      let(:billing) { BillingFactory.create(user: user, billing_type: :cash) }
      let(:other_billing) { BillingFactory.create(user: user) }

      before { BillingTransaction.create!(billing: billing, related_transaction: outcome) }

      context 'when there is only one billing transaction' do
        it 'should be valid' do
          expect(outcome).to be_valid
        end
      end

      context 'when there are multiple billing transactions' do
        before { BillingTransaction.create!(billing: other_billing, related_transaction: outcome) }

        it 'should not be valid' do
          expect(outcome).not_to be_valid
          expect(outcome.errors[:billing_transactions]).to include('Only one billing is allowed per transaction')
        end
      end
    end

    describe '#billing_transaction_changed' do
      let(:outcome) { OutcomeFactory.create(balance: balance) }
      let(:billing) { BillingFactory.create(user: user) }
      let(:other_billing) { BillingFactory.create(user: user) }

      context 'when there are persisted billing_transactions and new ones' do
        before { BillingTransaction.create!(billing: billing, related_transaction: outcome) }

        it 'should remove persisted billing_transactions and keep new one' do
          expect do
            outcome.update!(billing_transactions_attributes: [{ billing_id: billing.id }])
          end.to raise_error(ActiveRecord::RecordInvalid, /New billing should be different from previous/)
        end
      end
    end
  end

  context '#before_update' do
    describe '#remove_previous_categorizations' do
      let(:income) { IncomeFactory.create(balance: balance) }
      let(:category) { CategoryFactory.create(name: 'Grocery') }
      let(:other_category) { CategoryFactory.create(name: 'Clothes') }

      context 'when there are persisted categorizations and new ones' do
        before { Categorization.create!(category: category, transaction_record: income) }

        it 'should remove persisted categorizations and keep new one' do
          income.update!(categorizations_attributes: [{ category_id: other_category.id }])

          expect(income.categorizations.count).to eq 1
          expect(income.categories.first).to eq other_category
        end
      end
    end

    describe '#remove_previouse_billing_transactions' do
      let(:outcome) { OutcomeFactory.create(balance: balance) }
      let(:billing) { BillingFactory.create(user: user) }
      let(:other_billing) { BillingFactory.create(user: user) }

      context 'when there are persisted billing_transactions and new ones' do
        before { BillingTransaction.create!(billing: billing, related_transaction: outcome) }

        it 'should remove persisted billing_transactions and keep new one' do
          outcome.update!(billing_transactions_attributes: [{ billing_id: other_billing.id }])

          expect(outcome.billing_transactions.count).to eq 1
          expect(outcome.billings.first).to eq other_billing
        end
      end
    end
  end

  context '#before_discard' do
    let(:outcome) { OutcomeFactory.create(balance: balance) }

    describe '#validate_transaction_date_in_current_month' do
      it 'should not allow discarding if created in a different month' do
        outcome.update(transaction_date: Time.zone.today.prev_month)

        expect { outcome.discard! }.to raise_error(
          Errors::UnprocessableEntity, /Can only delete outcomes created in the current month/
        )
      end

      it 'should allow discarding if created in the same month' do
        outcome.update(transaction_date: Time.zone.today)

        expect(outcome.discard).to be_truthy
      end
    end
  end

  context '#after_update' do
    describe '#update_payment' do
      context 'when outcome is :current' do
        context 'when there is :applied payment' do
          let(:outcome) { OutcomeFactory.create(balance: balance, amount: 5_000) }

          subject { outcome.update!(amount: 10_000) }

          before { outcome.payments.hold.first.applied! }

          it 'should update payment amount' do
            expect(outcome.payments.applied.first.amount).to eq 5_000
            subject
            expect(outcome.payments.applied.first.amount).to eq 10_000
          end
        end
      end
    end
  end
end
