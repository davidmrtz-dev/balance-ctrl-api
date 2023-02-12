class Payment < ApplicationRecord
  belongs_to :paymentable, polymorphic: true

  validate :one_payment_for_current_paymentable

  delegate :balance, to: :paymentable

  after_create { paymentable.reload }

  after_create :update_current_balance

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

  def update_current_balance
    if is_current_paymentable_of?(Income, paymentable)
      balance.current_amount += amount
      balance.save
    elsif is_current_paymentable_of?(Outcome, paymentable)
      balance.current_amount -= amount
      balance.save
    end
  end

  def is_current_paymentable_of?(class_of, instance)
    instance.instance_of?(class_of) &&
      instance.transaction_type.eql?('current')
  end
end
