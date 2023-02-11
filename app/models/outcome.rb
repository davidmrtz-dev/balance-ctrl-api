class Outcome < ApplicationRecord
  belongs_to :balance

  has_many :payments, dependent: :destroy

  enum outcome_type: { current: 0, fixed: 1 }

  validate :only_one_payment_for_current_outcome

  private

  def only_one_payment_for_current_outcome
    errors.add(:payments, 'current outcome can only have one payment') if payments.size > 1 && outcome_type.eql?(:current)
  end
end
