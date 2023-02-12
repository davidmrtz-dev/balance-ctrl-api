class Payment < ApplicationRecord
  belongs_to :paymentable, polymorphic: true

  validate :one_payment_for_current_outcome, if: -> { paymentable&.instance_of?(Outcome) }
  validate :one_payment_for_current_income, if: -> { paymentable&.instance_of?(Income) }

  delegate :balance, to: :paymentable

  after_create { paymentable&.reload }

  # after_create :update_current_balance

  private

  def one_payment_for_current_outcome
    # byebug
    errors.add(:outcome, 'of type current can only have one payment') if
      paymentable.payments.size > 0 && paymentable.outcome_type.eql?('current')
  end

  def one_payment_for_current_income
    # byebug
    errors.add(:income, 'of type current can only have one payment') if
      paymentable.payments.size > 0 && paymentable.income_type.eql?('current')
  end

  # def update_current_balance
  #   if paymentable.instance_of?(Outcome) &&
  #     paymentable&.outcome_type.eql?('current')

  #     balance.current_amount -= amount
  #     balance.save
  #   elsif paymentable.instance_of?(Income) &&
  #     paymentable&.income_type.eql?('current')

  #     balance.current_amount += amount
  #     balance.save
  #   end
  # end
end
