class Payment < ApplicationRecord
  belongs_to :paymentable, polymorphic: true

  enum status: { hold: 0, pending: 1, applied: 2, expired: 3, cancelled: 4, refund: 5 }, _default: :hold

  validate :only_one_not_refund_for_current, on: :create
  validate :only_one_refund_for_current, on: :create

  private

  def only_one_not_refund_for_current
    if paymentable&.transaction_type.eql?('current') &&
       paymentable.payments.count.positive? &&
       status != 'refund'
      errors.add(:paymentable, 'of type current can only have one applied payment')
    end
  end

  def only_one_refund_for_current
    if paymentable&.transaction_type.eql?('current') &&
       paymentable.payments.refund.count.positive?
      errors.add(:paymentable, 'of type current can only have one refund payment')
    end
  end
end
