class Payment < ApplicationRecord
  belongs_to :paymentable, polymorphic: true
  has_and_belongs_to_many :billing_informations

  enum status: { hold: 0, pending: 1, applied: 2, expired: 3 }, _default: :hold

  validate :one_payment_for_current_paymentable, on: :create

  private

  def one_payment_for_current_paymentable
    if paymentable&.transaction_type.eql?('current') &&
       paymentable.payments.count.positive?
      errors.add(:paymentable, 'of type current can only have one payment')
    end
  end
end
