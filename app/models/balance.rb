class Balance < ApplicationRecord
  belongs_to :user
  has_many :outcomes, dependent: :destroy
  has_many :incomes, dependent: :destroy

  def total_income
    incomes.sum(:amount)
  end

  def total_expenses
    outcomes.sum(:amount)
  end
end
