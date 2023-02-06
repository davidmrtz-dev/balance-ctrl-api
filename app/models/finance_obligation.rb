class FinanceObligation < ApplicationRecord
  belongs_to :balance

  enum obligation_type: { fixed: 0, current: 1 }

  scope :fixed, -> { where(obligation_type: :fixed) }
  scope :current, -> { where(obligation_type: :current) }
end
