class BillingTransaction < ApplicationRecord
  after_create :update_payments, if: -> { related_transaction.transaction_type.eql?('current') }
  belongs_to :billing
  belongs_to :related_transaction, class_name: 'Transaction', foreign_key: :transaction_id,
                                   inverse_of: :billing_transactions

  private

  def update_payments
    if %w[cash debit].include?(billing.billing_type)
      related_transaction.payments.each(&:applied!)
    else
      related_transaction.payments.each(&:reset_to_hold)
    end
  end
end
