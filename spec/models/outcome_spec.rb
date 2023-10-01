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
    it { should_not allow_value(1.day.from_now).for(:transaction_date) }
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

    describe '#only_one_billing' do
      let(:billing) { BillingFactory.create(user: user) }
      let(:other_billing) { BillingFactory.create(user: user) }

      subject(:outcome) { OutcomeFactory.create(balance: balance) }

      context 'when there is only one billing transaction' do
        let!(:billing_transaction) { BillingTransaction.create!(billing: billing, related_transaction: outcome) }

        it 'does not add error' do
          expect(outcome).to be_valid
        end
      end

      context 'when there are multiple billing transactions' do
        let!(:billing_transaction_1) { BillingTransaction.create!(billing: billing, related_transaction: outcome) }
        let!(:billing_transaction_2) do
          BillingTransaction.create!(billing: other_billing, related_transaction: outcome)
        end

        it 'adds error' do
          expect(outcome).not_to be_valid
          expect(outcome.errors[:billing_transactions]).to include('Only one billing is allowed per outcome')
        end
      end
    end
  end

  context 'when outcome is :current' do
    let!(:outcome) do
      OutcomeFactory.create(balance: balance, amount: 5_000)
    end

    context '#after_create' do
      describe '#substract_balance_amount' do
        it 'should substract update balance current_amount' do
          expect(balance.current_amount).to eq 5_000
        end

        it 'should match the payment amount' do
          expect(outcome.payments.first.amount).to eq 5_000
        end
      end

      describe '#generate_payment' do
        subject(:transaction) { OutcomeFactory.create(balance: balance) }

        it 'should create one payment' do
          expect { transaction }.to change { Payment.count }.by 1
        end

        it 'should set payment status as :applied' do
          expect(transaction.payments.first.status).to eq 'applied'
        end
      end
    end

    context '#before_save' do
      describe '#update_balance_amount' do
        it 'should add the diff from the amount when is positive' do
          expect(balance.current_amount).to eq 5_000
          outcome.update!(amount: 2_500)
          expect(balance.current_amount).to eq 7_500
        end

        it 'should substract the diff from the amount when is negative' do
          expect(balance.current_amount).to eq 5_000
          outcome.update!(amount: 7_500)
          expect(balance.current_amount).to eq 2_500
        end

        it 'should update the corresponding payment amount' do
          outcome.update!(amount: 2_500)
          expect(outcome.payments.first.amount).to eq 2_500
        end
      end
    end

    context '#before_destroy' do
      describe '#add_balance_amount' do
        it 'should return the amount to balance current_amount' do
          outcome.destroy!

          expect(balance.current_amount).to eq 10_000
        end

        it 'should match the payment amount' do
          expect(outcome.payments.last.amount).to eq 5_000
        end
      end
    end
  end

  context 'when outcome is :fixed' do
    let(:outcome) do
      OutcomeFactory.create(
        balance: balance,
        transaction_type: :fixed,
        amount: 12_000,
        quotas: 12
      )
    end

    context '#after_create' do
      describe '#generate_payments' do
        it "'should create n 'quotas' payments" do
          expect do
            OutcomeFactory.create(
              balance: balance,
              amount: 12_000,
              transaction_type: :fixed,
              transaction_date: Time.zone.now,
              quotas: 12
            )
          end.to change { Payment.count }.by 12
        end

        it "should create payments with state as 'hold'" do
          expect(outcome.payments.pluck(:status).uniq.first).to eq 'hold'
        end

        it 'should create payment with amount as outcome.amount / outcome.quotas' do
          expect(outcome.payments.last.amount).to eq outcome.amount / outcome.quotas
        end
      end
    end
  end

  context '#before_save' do
    describe '#remove_previous_categorizations' do
      let(:category) { CategoryFactory.create(name: 'Grocery') }
      let(:other_category) { CategoryFactory.create(name: 'Clothes') }

      subject(:outcome) { OutcomeFactory.create(balance: balance) }

      before { outcome.categories << category }

      context 'when there are persisted categorizations and new ones' do
        it 'should remove persisted categorizations and keep new one' do
          outcome.update!(categorizations_attributes: [{ category_id: other_category.id }])

          expect(outcome.categorizations.count).to eq 1
          expect(outcome.categories.first).to eq other_category
        end
      end
    end

    describe '#remove_previouse_billing_transactions' do
      let(:billing) { BillingFactory.create(user: user) }
      let(:other_billing) { BillingFactory.create(user: user) }

      subject(:outcome) { OutcomeFactory.create(balance: balance) }

      before { outcome.billings << billing }

      context 'when there are persisted billing_transactions and new ones' do
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

    describe '#check_same_month' do
      it 'should not allow discarding if created in a different month' do
        outcome.update(created_at: Time.zone.today.prev_month)

        expect { outcome.discard! }.to raise_error(
          Errors::UnprocessableEntity, /Can only delete outcomes created in the current month/
        )
      end

      it 'should allow discarding if created in the same month' do
        outcome.update(created_at: Time.zone.today)

        expect(outcome.discard).to be_truthy
      end
    end
  end
end
