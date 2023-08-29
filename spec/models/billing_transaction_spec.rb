require 'rails_helper'

RSpec.describe BillingTransaction, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:billing) }
    it { is_expected.to belong_to(:related_transaction).class_name('Transaction').with_foreign_key(:transaction_id) }
  end

  describe 'database constraints' do
    let(:user) { UserFactory.create(password: 'password') }
    let(:balance) { BalanceFactory.create(user: user, current_amount: 10_000) }
    let(:billing) { BillingFactory.create(user: user) }
    let(:outcome) do
      OutcomeFactory.create(
        balance: balance,
        transaction_type: :fixed,
        amount: 12_000,
        quotas: 12
      )
    end

    it 'prevents duplicate billing_transaction records' do
      BillingTransaction.create(billing: billing, related_transaction: outcome)

      duplicate_billing_transaction = BillingTransaction.new(billing: billing, related_transaction: outcome)
      expect { duplicate_billing_transaction.save }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
