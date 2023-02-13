class Payment < ApplicationRecord
  belongs_to :paymentable, polymorphic: true

  enum status: { pending: 0, applied: 1 }, _default: :pending

  after_create { paymentable.reload }

  validate :one_payment_for_current_paymentable

  private

  def one_payment_for_current_paymentable
    if paymentable&.transaction_type.eql?('current') &&
        paymentable.payments.count > 0
      errors.add(:paymentable, 'of type current can only have one payment')
    end
  end
end
