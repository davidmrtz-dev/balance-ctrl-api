class FinanceActive < ApplicationRecord
  belongs_to :balance

  enum income_frequency: { weekly: 0, biweekly: 1, monthly: 2 }
  enum active_type: { fixed: 0, current: 1 }

  after_create :update_current_balance

  private

  def update_current_balance
    balance.current_amount += self.amount
  end
end
