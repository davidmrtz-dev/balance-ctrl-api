class Payment < ApplicationRecord
  belongs_to :paymentable, polymorphic: true

  enum status: { pending: 0, applied: 1 }, _default: :pending

  validate :one_payment_for_current_paymentable, on: :create

  private

  def one_payment_for_current_paymentable
    if paymentable&.transaction_type.eql?('current') &&
       paymentable.payments.count.positive?
      errors.add(:paymentable, 'of type current can only have one payment')
    end
  end
end
