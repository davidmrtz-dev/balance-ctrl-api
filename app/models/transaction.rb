class Transaction < ApplicationRecord
  belongs_to :balance

  has_many :payments, as: :paymentable, dependent: :destroy

  enum transaction_type: { current: 0, fixed: 1 }, _default: :current
  enum frequency: { weekly: 0, biweekly: 1, monthly: 2 }

  after_create :generate_payment, if: -> { transaction_type.eql?('current') }

  validates :amount, numericality: { greater_than_or_equal_to: 1 }, on: %i[create update]

  private

  def generate_payment
    payments.create!(amount: self.amount, status: :applied)
  end
end
