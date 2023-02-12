class Transaction < ApplicationRecord
  belongs_to :balance

  enum transaction_type: { current: 0, fixed: 1 }
  enum frequency: { weekly: 0, biweekly: 1, monthly: 2 }
end
