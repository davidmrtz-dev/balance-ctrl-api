class Payment < ApplicationRecord
  belongs_to :paymentable, polymorphic: true

  validate :one_payment_for_current_outcome
  after_create { paymentable.reload }

  private

  def one_payment_for_current_outcome
    if paymentable.instance_of?(Outcome) &&
      paymentable&.outcome_type.eql?('current')
      errors.add(:outcome, 'of type current can only have one payment') if paymentable.payments.size > 0
    end
  end
end
