class Balance < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy
  has_many :incomes, dependent: :destroy
  has_many :outcomes, dependent: :destroy
  has_many :balance_payments, dependent: :destroy
  has_many :payments, through: :balance_payments

  default_scope -> { order(created_at: :desc) }

  def total_incomes
    incomes.sum(:amount)
  end

  def total_outcomes
    outcomes.sum(:amount)
  end
end
