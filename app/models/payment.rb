class Payment < ApplicationRecord
  belongs_to :paymentable, polymorphic: true
  has_many :balance_payments, dependent: :destroy
  has_many :balances, through: :balance_payments

  belongs_to :refund, class_name: 'Payment', optional: true

  enum status: { hold: 0, pending: 1, applied: 2, expired: 3, refund: 4 }, _default: :hold

  after_create :add_to_balance_amount, if: -> { refund? }
  before_update :substract_from_balance_amount, if: -> { applied? && status_was != 'applied' }
  before_update :update_balance_amount, if: -> { applied? && status_was.eql?('applied') }

  validate :only_one_payment_for_current, on: :create, if: -> { paymentable&.transaction_type.eql?('current') }
  validate :only_one_refund_for_current, on: :create, if: -> { paymentable&.transaction_type.eql?('current') }

  scope :applicable, -> { where.not(status: %i[expired refund]) }

  def payment_number
    "#{paymentable.payments.applicable.where('id <= ?', id).count}/#{paymentable.payments.applicable.count}"
  end

  private

  def add_to_balance_amount
    paymentable.balance.current_amount += amount
    paymentable.balance.save
  end

  def substract_from_balance_amount
    paymentable.balance.current_amount -= amount
    paymentable.balance.save
  end

  def update_balance_amount
    paymentable.balance.current_amount += (amount_was - amount)
    paymentable.balance.save
  end

  def only_one_payment_for_current
    if paymentable.payments.count.positive? &&
       status != 'refund'
      errors.add(:paymentable, 'of type current can only have one payment')
    end
  end

  def only_one_refund_for_current
    return unless paymentable.payments.refund.count.positive?

    errors.add(:paymentable, 'of type current can only have one refund')
  end
end
