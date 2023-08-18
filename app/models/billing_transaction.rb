class BillingTransaction < ApplicationRecord
  belongs_to :billing
  belongs_to :related_transaction, class_name: 'Transaction', foreign_key: :transaction_id
end
