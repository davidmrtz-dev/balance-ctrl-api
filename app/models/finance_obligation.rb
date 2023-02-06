class FinanceObligation < ApplicationRecord
  belongs_to :balance

  enum obligation_type: { fixed: 0, current: 1 }
end
