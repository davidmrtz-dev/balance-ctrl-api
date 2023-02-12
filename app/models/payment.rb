class Payment < ApplicationRecord
  belongs_to :paymentable, polymorphic: true

  validate :one_payment_for_current_outcome
  after_create { paymentable.reload }

  private

  def one_payment_for_current_outcome
    byebug
    if paymentable.paymentable_type.eql?('Outcome')
      && paymentable&.outcome_type.eql?('current')
      errors.add(:self, 'current outcome can only have one payment') if outcome.payments.size > 0
    end
  end
end
