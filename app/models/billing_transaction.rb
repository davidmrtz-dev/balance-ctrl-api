class BillingTransaction < ApplicationRecord
  after_create :update_payments, if: -> { related_transaction.transaction_type.eql?('current') }
  belongs_to :billing
  belongs_to :related_transaction, class_name: 'Transaction', foreign_key: :transaction_id,
                                   inverse_of: :billing_transactions

  private

  def update_payments
    return unless %w[cash debit].include?(billing.billing_type)

    related_transaction.payments.each do |p|
      BalancePayment.create!(
        balance: related_transaction.balance,
        payment: p
      )
      p.applied!
    end
  end
end
