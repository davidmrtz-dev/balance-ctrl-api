class Balance < ApplicationRecord
  belongs_to :user
  has_many :finance_obligations, dependent: :destroy
  has_many :finance_actives, dependent: :destroy

  def total_income
    finance_actives.sum(:amount)
  end

  def total_expenses
    finance_obligations.sum(:amount)
  end

  def total_balance
    total_income - total_expenses
  end
end
