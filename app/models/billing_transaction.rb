class BillingTransaction < ApplicationRecord
  after_create :update_payments, if: -> { related_transaction.transaction_type.eql?('current') && ['cash', 'debit'].include?(billing.billing_type) }
  belongs_to :billing
  belongs_to :related_transaction, class_name: 'Transaction', foreign_key: :transaction_id,
                                   inverse_of: :billing_transactions

  private

  def update_payments
    related_transaction.payments.each(&:applied!)
  end
end
