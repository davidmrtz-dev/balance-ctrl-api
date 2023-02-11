class Outcome < ApplicationRecord
  belongs_to :balance

  after_create :update_current_balance

  private

  def update_current_balance
    balance.current_amount -= self.amount
  end
end
