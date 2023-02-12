class Transaction < ApplicationRecord
  self.inheritance_column = :_type_disabled
  belongs_to :balance

  enum type: { income: 0, outcome: 1 }
  enum transaction_type: { current: 0, fixed: 1 }
  enum frequency: { weekly: 0, biweekly: 1, monthly: 2 }
end
