class Income < ApplicationRecord
  belongs_to :balance

  has_many :payments, as: :paymentable, dependent: :destroy

  enum income_frequency: { weekly: 0, biweekly: 1, monthly: 2 }
  enum income_type: { current: 0, fixed: 1 }
end
