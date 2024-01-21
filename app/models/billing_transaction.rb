class BillingTransaction < ApplicationRecord
  belongs_to :billing
  belongs_to :related_transaction, class_name: 'Transaction', foreign_key: :transaction_id,
                                   inverse_of: :billing_transactions
end
