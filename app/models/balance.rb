class Balance < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy
  has_many :incomes, dependent: :destroy
  has_many :outcomes, dependent: :destroy
  has_many :balance_payments, dependent: :destroy
  has_many :payments, through: :balance_payments

  default_scope -> { order(id: :desc) }

  def amount_incomes
    applied_incomes.sum(&:amount)
  end

  def amount_paid
    applied_outcomes.sum(&:amount)
  end

  def amount_to_be_paid
    pending_outcomes.sum(&:amount)
  end

  def amount_for_payments
    amount_paid + amount_to_be_paid
  end

  def outcomes_applied_payments
    applied_outcomes
  end

  def current?
    Time.zone.now.month == month && Time.zone.now.year == year
  end

  private

  def applied_incomes
    income_ids = applied_incomes_ids
    payments.applied.where(paymentable_id: income_ids)
  end

  def applied_incomes_ids
    transaction_ids(type: 'Income')
  end

  def applied_outcomes
    outcome_ids = applied_outcomes_ids
    payments.applied.where(paymentable_id: outcome_ids)
  end

  def applied_outcomes_ids
    transaction_ids(type: 'Outcome')
  end

  def pending_outcomes
    payments.pending.where(paymentable: outcomes)
  end

  def transaction_ids(type:)
    transaction_ids = payments.applied.pluck(:paymentable_id)
    Transaction.where(id: transaction_ids, type: type).ids
  end
end
