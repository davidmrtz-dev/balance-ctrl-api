class Payment < ApplicationRecord
  belongs_to :paymentable, polymorphic: true

  # validate :one_payment_for_current_outcome, if: -> { outcome&.outcome_type.eql?('current') }
  # after_create { outcome.reload }

  # private

  # def one_payment_for_current_outcome
  #   errors.add(:self, 'current outcome can only have one payment') if outcome.payments.size > 0
  # end
end
