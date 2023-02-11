class Outcome < ApplicationRecord
  belongs_to :balance

  has_many :payments, dependent: :destroy

  enum outcome_type: { current: 0, fixed: 1 }
end
