class Transaction < ApplicationRecord
  include Discard::Model

  belongs_to :balance
  has_many :payments, as: :paymentable, dependent: :destroy
  has_many :billing_transactions, dependent: :destroy
  has_many :billings, through: :billing_transactions
  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations

  enum transaction_type: { current: 0, fixed: 1 }, _default: :current
  enum frequency: { weekly: 0, biweekly: 1, monthly: 2 }

  validates :transaction_date, presence: true
  validates :amount, numericality: { greater_than: 0.0 }
  validate :transaction_date_not_after_today, :transaction_date_current_month

  scope :with_balance_and_user, -> { joins(balance: :user) }
  scope :from_user, ->(user) { where({ balance: { user: user } }) }

  default_scope -> { kept }

  accepts_nested_attributes_for :categorizations
  accepts_nested_attributes_for :billing_transactions

  def current_billing
    return unless billings.any?

    billings.first
  end

  private

  def transaction_date_not_after_today
    return if transaction_date.nil? || transaction_date <= Time.zone.now.beginning_of_day

    errors.add(:transaction_date, 'cannot be after today')
  end

  def transaction_date_current_month
    return if transaction_date.nil? || transaction_date.month == Time.zone.now.month

    errors.add(:transaction_date, 'should be in current month')
  end
end
