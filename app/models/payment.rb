class Payment < ApplicationRecord
  belongs_to :paymentable, polymorphic: true

  enum status: { hold: 0, pending: 1, applied: 2, expired: 3, cancelled: 4, refund: 5 }, _default: :hold

  before_update :update_balance_amount, if: -> { status_changed? }
  after_create :update_balance_amount

  validate :only_one_not_refund_for_current, on: :create, if: -> { paymentable&.transaction_type.eql?('current') }
  validate :only_one_refund_for_current, on: :create, if: -> { paymentable&.transaction_type.eql?('current') }

  private

  def update_balance_amount
    if applied?
      paymentable.balance.current_amount -= amount
    elsif refund?
      paymentable.balance.current_amount += amount
    end

    paymentable.balance.save
  end

  def only_one_not_refund_for_current
    if paymentable.payments.count.positive? &&
       status != 'refund'
      errors.add(:paymentable, 'of type current can only have one applied payment')
    end
  end

  def only_one_refund_for_current
    if paymentable.payments.refund.count.positive?
      errors.add(:paymentable, 'of type current can only have one refund payment')
    end
  end
end
