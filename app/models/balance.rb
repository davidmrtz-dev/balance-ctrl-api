class Balance < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy
  has_many :incomes, dependent: :destroy
  has_many :outcomes, dependent: :destroy
  has_many :balance_payments, dependent: :destroy
  has_many :payments, through: :balance_payments

  default_scope -> { order(created_at: :desc) }

  def amount_incomes
    incomes.sum(:amount)
  end

  def amount_outcomes
    outcomes.sum(:amount)
  end

  def amount_paid
    payments.applied.sum(:amount)
  end

  def amount_to_be_paid
    payments.pending.sum(:amount)
  end

  def amount_for_payments
    amount_paid + amount_to_be_paid
  end

  def is_current?
    Time.zone.now.month == month && Time.zone.now.year == year
  end
end
