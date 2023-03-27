class Transaction < ApplicationRecord
  include Discard::Model

  belongs_to :balance
  has_many :payments, as: :paymentable, dependent: :destroy

  enum transaction_type: { current: 0, fixed: 1 }, _default: :current
  enum frequency: { weekly: 0, biweekly: 1, monthly: 2 }

  before_destroy :check_same_month
  before_discard :check_same_month
  after_create :generate_payment, if: -> { transaction_type.eql?('current') }

  validates :transaction_date, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validate :transaction_date_not_after_today, :transaction_date_current_month

  scope :with_balance_and_user, -> { joins(balance: :user) }
  scope :from_user, ->(user) { where({ balance: { user: user } }) }

  # default_scope -> { kept }

  private

  def check_same_month
    if created_at.month != Time.zone.now.month
      errors.add(:base, "Can only delete transactions created in the current month")
      throw :abort
    end
  end

  def transaction_date_not_after_today
    return if transaction_date.nil? || transaction_date < Time.zone.now

    errors.add(:transaction_date, 'can not be after today')
  end

  def transaction_date_current_month
    return if transaction_date.nil? || transaction_date.month == Time.zone.now.month

    errors.add(:transaction_date, 'should be in current month')
  end

  def generate_payment
    payments.create!(amount: amount, status: :applied)
  end
end
