class Payment < ApplicationRecord
  belongs_to :paymentable, polymorphic: true
  has_many :balance_payments, dependent: :destroy
  has_many :balances, through: :balance_payments

  belongs_to :refund, class_name: 'Payment', optional: true

  enum status: { hold: 0, pending: 1, applied: 2, expired: 3, refund: 4 }, _default: :hold

  before_update :attach_to_balance_amount, if: -> { refund? && status_was == 'hold' }
  before_update :detach_from_balance_amount, if: -> { applied? && (status_was == 'hold' || status_was == 'pending') }
  before_update :update_balance_amount, if: -> { applied? && status_was.eql?('applied') }

  validate :only_one_applied_for_current, on: :create, if: -> { paymentable&.transaction_type.eql?('current') }
  validate :only_one_refund_for_current, on: :create, if: -> { paymentable&.transaction_type.eql?('current') }

  scope :applicable, -> { where.not(status: %i[expired refund]) }

  default_scope { order(status: :desc, paid_at: :asc) }

  def payment_number
    "#{paymentable.payments.applicable.where('id <= ?', id).count}/#{paymentable.payments.applicable.count}"
  end

  private

  def balance
    balances.first
  end

  def outcome?
    paymentable.type.eql?('Outcome')
  end

  def income?
    paymentable.type.eql?('Income')
  end

  def save_balance(quantity = nil)
    balance.update!(current_amount: quantity || balance.current_amount)
  end

  def attach_to_balance_amount
    if outcome?
      quantity = balance.current_amount += amount
    elsif income?
      quantity = balance.current_amount -= amount
    end

    save_balance(quantity)
  end

  def detach_from_balance_amount
    if outcome?
      quantity = balance.current_amount -= amount
    elsif income?
      quantity = balance.current_amount += amount
    end

    save_balance(quantity)
  end

  def update_balance_amount
    if outcome?
      quantity = paymentable.balance.current_amount += (amount_was - amount)
    elsif income?
      quantity = paymentable.balance.current_amount -= (amount_was - amount)
    end

    save_balance(quantity)
  end

  def only_one_applied_for_current
    if paymentable.payments.count.positive? &&
       status == 'applied'
      errors.add(:paymentable, 'of type current can only have one payment')
    end
  end

  def only_one_refund_for_current
    return unless paymentable.payments.refund.count.positive?

    errors.add(:paymentable, 'of type current can only have one refund')
  end
end
