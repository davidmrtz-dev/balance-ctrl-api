class Transaction < ApplicationRecord
  include Discard::Model

  belongs_to :balance
  has_many :payments, as: :paymentable, dependent: :destroy
  has_many :billing_transactions
  has_many :billings, through: :billing_transactions
  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations

  enum transaction_type: { current: 0, fixed: 1 }, _default: :current
  enum frequency: { weekly: 0, biweekly: 1, monthly: 2 }

  before_update :remove_previous_categorizations, if: :should_remove_previous_categorizations?
  after_create :generate_payment, if: -> { transaction_type.eql? 'current' }
  before_destroy :check_same_month, if: -> { transaction_type.eql? 'current' }
  before_discard :check_same_month, if: -> { transaction_type.eql? 'fixed' }

  validates :transaction_date, presence: true
  validates :amount, numericality: { greater_than: 0.0 }
  validate :transaction_date_not_after_today, :transaction_date_current_month

  scope :with_balance_and_user, -> { joins(balance: :user) }
  scope :from_user, ->(user) { where({ balance: { user: user } }) }

  default_scope -> { kept }

  accepts_nested_attributes_for :categorizations
  accepts_nested_attributes_for :billing_transactions

  private

  def remove_previous_categorizations
    categorizations.each do |categorization|
      categorization.destroy! if categorization.persisted?
    end
  end

  def should_remove_previous_categorizations?
    categorizations.any?(&:persisted?) && categorizations.any?(&:new_record?)
  end

  def check_same_month
    return unless created_at.month != Time.zone.now.month

    errors.add(:base, 'Can only delete transactions created in the current month')
    throw :abort
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
