class FinanceObligation < ApplicationRecord
  belongs_to :balance

  enum obligation_type: { fixed: 0, current: 1 }
  enum status: { active: 0, inactive: 1}
end
