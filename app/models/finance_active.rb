class FinanceActive < ApplicationRecord
  belongs_to :balance

  enum income_frequency: { weekly: 0, biweekly: 1, monthly: 2 }
  enum active_type: { fixed: 0, current: 1 }
end
