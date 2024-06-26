class Balance < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy
  has_many :incomes, dependent: :destroy
  has_many :outcomes, dependent: :destroy
  has_many :balance_payments, dependent: :destroy
  has_many :payments, through: :balance_payments

  default_scope -> { order(id: :desc) }

  def amount_incomes
    applied_incomes_payments.sum(&:amount)
  end

  def amount_outcomes_current
    outcomes_payments(outcomes_current_ids).sum(&:amount)
  end

  def line_chart_data
    current_payments = outcomes_payments(outcomes_current_ids)
    fixed_payments = outcomes_payments(outcomes_fixed_ids)

    current_payments_by_week = calculate_payments_by_week(current_payments)
    fixed_payments_by_week = calculate_payments_by_week(fixed_payments)

    {
      weeks: current_payments_by_week.keys.sort.map { |week| "Week #{week}" },
      current: current_payments_by_week.values,
      fixed: fixed_payments_by_week.values
    }
  end

  def amount_outcomes_fixed
    outcomes_payments(outcomes_fixed_ids).sum(&:amount)
  end

  def amount_after_payments
    amount_incomes - amount_for_payments
  end

  def amount_paid
    applied_outcomes_payments.sum(&:amount)
  end

  def amount_to_be_paid
    payments.pending.sum(&:amount)
  end

  def amount_for_payments
    amount_paid + amount_to_be_paid
  end

  def outcomes_applied_payments
    applied_outcomes_payments
  end

  def comparison_percentage
    return unless before_balance

    c_amount = amount_for_payments
    l_amount = before_balance.amount_for_payments

    change = ((c_amount - l_amount).to_f / l_amount.abs) * 100
    prefix = change.positive? ? '-' : '+'
    change = change.abs

    "#{prefix}#{change.round(2)}"
  end

  def current?
    Time.zone.now.month == month && Time.zone.now.year == year
  end

  private

  def calculate_payments_by_week(payments)
    payments_by_week = Hash.new(0)

    payments.each do |payment|
      next if payment.paid_at.nil?

      week_number = ((payment.paid_at.day - 1) / 7) + 1
      payments_by_week[week_number] += payment.amount
    end

    payments_by_week
  end

  def before_balance
    user.balances.where('id < ?', id).first
  end

  def next_balance
    user.balances.where('id > ?', id).last
  end

  def applied_incomes_payments
    income_ids = applied_incomes_ids
    payments.applied.where(paymentable_id: income_ids)
  end

  def applied_incomes_ids
    t_applied_payments_ids(type: 'Income')
  end

  def applied_outcomes_payments
    outcome_ids = applied_outcomes_ids
    payments.applied.where(paymentable_id: outcome_ids)
  end

  def outcomes_payments(outcomes_ids)
    payments.where(paymentable_id: outcomes_ids)
  end

  def applied_outcomes_ids
    t_applied_payments_ids(type: 'Outcome')
  end

  def outcomes_current_ids
    t_payments_ids(type: 'Outcome', transaction_type: 'current')
  end

  def outcomes_fixed_ids
    t_payments_ids(type: 'Outcome', transaction_type: 'fixed')
  end

  def t_applied_payments_ids(type:)
    Transaction.where(id: payments.applied.pluck(:paymentable_id), type: type).ids
  end

  def t_payments_ids(type:, transaction_type: nil)
    transactions = Transaction.where(id: payments.pending_or_applied.pluck(:paymentable_id), type: type)
    transactions = transactions.where(transaction_type: transaction_type) if transaction_type.present?
    transactions.ids
  end
end
