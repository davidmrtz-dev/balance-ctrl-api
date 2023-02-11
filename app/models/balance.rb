class Balance < ApplicationRecord
  belongs_to :user
  has_many :outcomes, dependent: :destroy
  has_many :incomes, dependent: :destroy

  delegate :fixed, to: :outcomes, prefix: :payments
  delegate :current, to: :outcomes, prefix: :payments

  def total_income
    incomes.sum(:amount)
  end

  def total_expenses
    outcomes.sum(:amount)
  end
end
