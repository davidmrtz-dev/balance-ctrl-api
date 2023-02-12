class Payment < ApplicationRecord
  belongs_to :paymentable, polymorphic: true

  validate :one_payment_for_current_paymentable

  delegate :balance, to: :paymentable

  after_create { paymentable.reload }

  after_create :update_current_balance

  private

  def one_payment_for_current_paymentable
    if paymentable.instance_of?(Income) &&
      paymentable.income_type.eql?('current') &&
        paymentable.payments.count > 0
      errors.add(:income, 'of type current can only have one payment')
    elsif paymentable.instance_of?(Outcome) &&
      paymentable.outcome_type.eql?('current') &&
        paymentable.payments.count > 0
      errors.add(:outcome, 'of type current can only have one payment')
    end
  end

  def update_current_balance
    if paymentable.instance_of?(Outcome) &&
      paymentable.outcome_type.eql?('current')

      balance.current_amount -= amount
      balance.save
    elsif paymentable.instance_of?(Income) &&
      paymentable.income_type.eql?('current')

      balance.current_amount += amount
      balance.save
    end
  end

  # def is_current_paymentable_of?(class, instance)
  #   instance.instance_of?(class) &&
  #     instance.type.eql?('current')
  # end
end
