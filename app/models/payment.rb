class Payment < ApplicationRecord
  belongs_to :paymentable, polymorphic: true

  enum status: { pending: 0, applied: 1 }, _default: :pending

  after_create { paymentable.reload }

  validate :one_payment_for_current_paymentable

  private

  def one_payment_for_current_paymentable
    if is_current_paymentable_of?(Income, paymentable) &&
        paymentable.payments.count > 0
      errors.add(:income, 'of type current can only have one payment')
    elsif is_current_paymentable_of?(Outcome, paymentable) &&
        paymentable.payments.count > 0
      errors.add(:outcome, 'of type current can only have one payment')
    end
  end

  def is_current_paymentable_of?(class_of, instance)
    instance.instance_of?(class_of) &&
      instance.transaction_type.eql?('current')
  end
end
