class Outcome < ApplicationRecord
  belongs_to :balance

  enum outcome_type: { fixed: 0, current: 1 }

  scope :fixed, -> { where(outcome_type: :fixed) }
  scope :current, -> { where(outcome_type: :current) }

  after_create :update_current_balance

  private

  def update_current_balance
    balance.current_amount -= self.amount
  end
end
