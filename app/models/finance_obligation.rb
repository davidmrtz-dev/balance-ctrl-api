class FinanceObligation < ApplicationRecord
  belongs_to :balance

  enum obligation_type: { fixed: 0, current: 1 }

  scope :fixed, -> { where(obligation_type: :fixed) }
  scope :current, -> { where(obligation_type: :current) }

  after_create :update_current_balance

  private

  def update_current_balance
    balance.current_amount -= self.amount
  end
end
